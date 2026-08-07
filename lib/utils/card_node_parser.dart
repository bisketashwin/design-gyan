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

    // Directives extraction defaults
    double slideAspectRatio = fallbackAspectRatio;
    String? cardWidth;

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('# ')) {
        title = trimmed.replaceFirst('# ', '').trim();
        continue;
      }

      if (trimmed.startsWith('<!--')) {
        // Parse slide-level aspect ratio (e.g., <!-- aspect-ratio: 1:1 --> or <!-- aspect-ratio: 1.777 -->)
        final arMatch = RegExp(r'<!--\s*aspect-ratio:\s*([0-9\.:]+)\s*-->').firstMatch(trimmed);
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

        // Parse custom card width override (e.g., <!-- card-width: 15% -->)
        final widthMatch = RegExp(r'<!--\s*card-width:\s*([^->]+)\s*-->').firstMatch(trimmed);
        if (widthMatch != null) {
          cardWidth = widthMatch.group(1)!.trim();
        }

        // Parse relative step tags (<!-- step: +1 -->) or absolute tags (<!-- step: 1 -->)
        final relMatch = RegExp(r'<!--\s*step:\s*\+(\d+)\s*-->').firstMatch(trimmed);
        final absMatch = RegExp(r'<!--\s*step:\s*(\d+)\s*-->').firstMatch(trimmed);

        if (relMatch != null) {
          currentRelativeLevel = int.parse(relMatch.group(1)!);
        } else if (absMatch != null) {
          currentRelativeLevel = int.parse(absMatch.group(1)!);
        }

        // Detect card boundary
        final cardDirective = RegExp(r'<!--\s*card(?::\d+)?\s*-->').firstMatch(trimmed);
        if (cardDirective != null) {
          if (currentRawCard != null) {
            rawCards.add(currentRawCard);
          }
          currentRelativeLevel = 0; // Reset relative level per card
          currentRawCard = _RawCardData(subPoints: []);
        }
        continue;
      }

      if (currentRawCard == null) continue;

      if (trimmed.startsWith('### ')) {
        currentRawCard.title = trimmed.replaceFirst('### ', '').trim();
        continue;
      }

      if (trimmed.startsWith('![')) {
        final imgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(trimmed);
        if (imgMatch != null) {
          currentRawCard.imageUrl = imgMatch.group(1);
        }
        continue;
      }

      if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        final rawText = trimmed.substring(2).trim();
        String? subImgUrl;
        String cleanText = rawText;

        final subImgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(rawText);
        if (subImgMatch != null) {
          subImgUrl = subImgMatch.group(1);
          cleanText = rawText.replaceAll(subImgMatch.group(0)!, '').trim();
        }

        currentRawCard.subPoints.add(
          _RawSubPoint(
            text: cleanText.isNotEmpty ? cleanText : null,
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

    // PASS 2: Calculate round-robin steps preserving explicit aspect ratio and card width
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
          aspectRatio: slideAspectRatio, // Preserved custom aspect ratio (e.g. 1.0)
          cardWidth: cardWidth,           // Preserved custom width string (e.g. "15%")
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