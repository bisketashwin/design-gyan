// lib/utils/card_node_parser.dart
import 'package:design_gyan/models/progressive_grid_models.dart';

class CardParseResult {
  final String title;
  final String? subheader;
  final String? signOff; 
  final String? footer;  
  final List<CardPointNode> cards;
  final int maxSteps;
  final double aspectRatio;
  final String? cardWidth;

  const CardParseResult({
    required this.title,
    this.subheader,
    this.signOff,
    this.footer,
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
    String? subheader;
    String? signOff;
    String? footer;
    final List<_RawCardData> rawCards = [];
    _RawCardData? currentRawCard;
    int currentRelativeLevel = 0;
    double slideAspectRatio = fallbackAspectRatio;
    String? cardWidth;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // 1. Extract Sign-off (Check ALWAYS, even inside card context)
      if (trimmed.startsWith('<!-- sign-off:') || trimmed.startsWith('Sign-off:')) {
        signOff = trimmed
            .replaceAll(RegExp(r'^(Sign-off:\s*|<!--\s*sign-off:\s*)'), '')
            .replaceAll('-->', '')
            .trim();
        continue;
      }

      // 2. Extract Footers (Check ALWAYS, even inside card context)
      if (trimmed.startsWith('## [source:') || trimmed.startsWith('Footer:') || trimmed.startsWith('<!-- footer:')) {
        footer = trimmed
            .replaceAll(RegExp(r'^(##\s*|Footer:\s*|<!--\s*footer:\s*)'), '')
            .replaceAll('-->', '')
            .trim();
        continue;
      }

      // 3. Extract Main Title
      if (trimmed.startsWith('# ')) {
        title = trimmed.replaceFirst('# ', '').trim();
        continue;
      }

      // 4. Extract Top-Level Subheader (before cards start)
      if (trimmed.startsWith('## ') && currentRawCard == null) {
        subheader = trimmed.replaceFirst('## ', '').trim();
        continue;
      }

      // 5. Directives
      if (trimmed.startsWith('<!--')) {
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

        final widthMatch = RegExp(r'card-width:\s*([^-\s>]+)').firstMatch(trimmed);
        if (widthMatch != null) {
          cardWidth = widthMatch.group(1)!.trim();
        }

        final relMatch = RegExp(r'step:\s*\+(\d+)').firstMatch(trimmed);
        final absMatch = RegExp(r'step:\s*(\d+)').firstMatch(trimmed);
        if (relMatch != null) {
          currentRelativeLevel = int.parse(relMatch.group(1)!);
        } else if (absMatch != null) {
          currentRelativeLevel = int.parse(absMatch.group(1)!);
        }

        final cardDirective = RegExp(r'<!--\s*card(?::\d+)?\s*-->').firstMatch(trimmed);
        if (cardDirective != null) {
          if (currentRawCard != null) {
            rawCards.add(currentRawCard);
          }
          currentRelativeLevel = 0;
          currentRawCard = _RawCardData(subPoints: []);
        }
        continue;
      }

      // Guard: Ignore card-specific parsing if no card block active
      if (currentRawCard == null) continue;

      // 6. Card Specific Titles / Headers
      if (trimmed.startsWith('### ') || trimmed.startsWith('## ')) {
        currentRawCard.title = trimmed.replaceFirst(RegExp(r'^###?\s*'), '').trim();
        continue;
      }

      // 7. Text-only bullet items / Sub-points inside card
      if (trimmed.startsWith('![') || trimmed.startsWith('* ') || trimmed.startsWith('- ') || !trimmed.startsWith('#')) {
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

        if (cleanText.isNotEmpty || subImgUrl != null) {
          currentRawCard.subPoints.add(
            _RawSubPoint(
              text: cleanText.isNotEmpty ? cleanText : null,
              imageUrl: subImgUrl,
              relativeLevel: currentRelativeLevel,
            ),
          );
        }
      }
    }

    if (currentRawCard != null) {
      rawCards.add(currentRawCard);
    }

    final int totalCards = rawCards.length;
    int maxCalculatedStep = totalCards > 0 ? totalCards : 1;
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
      subheader: subheader,
      signOff: signOff,
      footer: footer,
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