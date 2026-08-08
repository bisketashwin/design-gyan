import 'package:design_gyan/models/progressive_grid_models.dart';

class CardParseResult {
  final String title;
  final List<CardPointNode> cards;
  final int maxSteps;
  final double aspectRatio;
  final String? cardWidth;

  const CardParseResult({
    required this.title,
    required this.cards,
    required this.maxSteps,
    required this.aspectRatio,
    this.cardWidth,
  });
}
class CardNodeParser {
  const CardNodeParser();

  CardParseResult parseLines(List<String> lines, double fallbackAspectRatio) {
    String title = '';
    final List<_RawCardData> rawCards = [];
    _RawCardData? currentRawCard;
    int currentRelativeLevel = 0;

    double slideAspectRatio = fallbackAspectRatio;
    String? cardWidth;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('# ')) {
        title = trimmed.replaceFirst('# ', '').trim();
        continue;
      }

      if (trimmed.startsWith('<!--')) {
        // 1. Extract aspect ratio (e.g. aspect-ratio: 1:1)
        final arMatch = RegExp(r'aspect-ratio:\s*([0-9\.:]+)').firstMatch(trimmed);
        if (arMatch != null) {
          final val = arMatch.group(1)!;
          if (val.contains(':')) {
            final parts = val.split(':');
            final num = double.tryParse(parts[0]);
            final den = double.tryParse(parts[1]);
            if (num != null && den != null && den != 0) {
              slideAspectRatio = num / den;
            }
          } else {
            slideAspectRatio = double.tryParse(val) ?? slideAspectRatio;
          }
        }

        // 2. Extract card width (e.g. card-width: 25%)
        final widthMatch = RegExp(r'card-width:\s*([^-\s>]+)').firstMatch(trimmed);
        if (widthMatch != null) {
          cardWidth = widthMatch.group(1)!.trim();
        }

        // 3. Extract step tags (<!-- step: +1 --> or <!-- step: 1 -->)
        final relMatch = RegExp(r'step:\s*\+(\d+)').firstMatch(trimmed);
        final absMatch = RegExp(r'step:\s*(\d+)').firstMatch(trimmed);

        if (relMatch != null) {
          currentRelativeLevel = int.parse(relMatch.group(1)!);
        } else if (absMatch != null) {
          currentRelativeLevel = int.parse(absMatch.group(1)!);
        }

        // 4. Card boundary marker (<!-- card -->)
        final cardDirective = RegExp(r'<!--\s*card(?::\d+)?\s*-->').firstMatch(trimmed);
        if (cardDirective != null) {
          if (currentRawCard != null) {
            rawCards.add(currentRawCard);
          }
          currentRelativeLevel = 0; // Reset relative step counter for new card
          currentRawCard = _RawCardData(subPoints: []);
        }

        // Pass-through: ignore inline/mode directives without dropping execution context
        continue;
      }

      if (currentRawCard == null) continue;

      if (trimmed.startsWith('### ')) {
        currentRawCard.title = trimmed.replaceFirst('### ', '').trim();
        continue;
      }

      // Card main image (appears before any step markers)
      if (trimmed.startsWith('![') && currentRawCard.subPoints.isEmpty && currentRelativeLevel == 0) {
        final imgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(trimmed);
        if (imgMatch != null) {
          currentRawCard.imageUrl = imgMatch.group(1);
        }
        continue;
      }

      // Handles step items: bullet points (*, -) OR standalone image tags (![...])
      if (trimmed.startsWith('![') || trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        String? subImgUrl;
        String? cleanText;

        final imgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(trimmed);
        if (imgMatch != null) {
          subImgUrl = imgMatch.group(1);
          final textWithoutImg = trimmed.replaceAll(imgMatch.group(0)!, '').trim();
          cleanText = textWithoutImg.replaceFirst(RegExp(r'^[\*\-]\s*'), '').trim();
        } else {
          cleanText = trimmed.replaceFirst(RegExp(r'^[\*\-]\s*'), '').trim();
        }

        currentRawCard.subPoints.add(
          _RawSubPoint(
            text: (cleanText != null && cleanText.isNotEmpty) ? cleanText : null,
            imageUrl: subImgUrl,
            relativeLevel: currentRelativeLevel,
          ),
        );
      }
    }

    if (currentRawCard != null) {
      rawCards.add(currentRawCard);
    }

    final int totalCards = rawCards.length;
    int maxCalculatedStep = totalCards > 0 ? totalCards : 1;

    // Pass 2: Round-robin relative step mapping
    final List<CardPointNode> finalCards = [];

    for (int cIndex = 0; cIndex < totalCards; cIndex++) {
      final raw = rawCards[cIndex];
      final int cardIndexNumber = cIndex + 1;

      final List<SubPointData> finalSubPoints = raw.subPoints.map((sp) {
        final int calculatedGlobalStep = cardIndexNumber + (sp.relativeLevel * totalCards);

        if (calculatedGlobalStep > maxCalculatedStep) {
          maxCalculatedStep = calculatedGlobalStep;
        }

        return SubPointData(
          text: sp.text,
          imageUrl: sp.imageUrl,
          revealStep: calculatedGlobalStep,
        );
      }).toList();

      finalCards.add(
        CardPointNode(
          title: raw.title,
          imageUrl: raw.imageUrl,
          baseRevealStep: cardIndexNumber,
          aspectRatio: slideAspectRatio,
          cardWidth: cardWidth,
          subPoints: finalSubPoints,
        ),
      );
    }

    return CardParseResult(
      title: title,
      cards: finalCards,
      maxSteps: maxCalculatedStep,
      aspectRatio: slideAspectRatio,
      cardWidth: cardWidth,
    );
  }
}

class _RawCardData {
  String title;
  String? imageUrl;
  final List<_RawSubPoint> subPoints;

  _RawCardData({
    this.title = '',
    this.imageUrl,
    required this.subPoints,
  });
}

class _RawSubPoint {
  final String? text;
  final String? imageUrl;
  final int relativeLevel;

  _RawSubPoint({
    this.text,
    this.imageUrl,
    required this.relativeLevel,
  });
}