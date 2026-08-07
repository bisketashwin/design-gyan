import 'package:flutter/foundation.dart';

@immutable
class SubPointData {
  final String? text;
  final String? imageUrl;
  final int revealStep;

  const SubPointData({
    this.text,
    this.imageUrl,
    required this.revealStep,
  }) : assert(
         text != null || imageUrl != null,
         'SubPointData must contain at least text or an imageUrl.',
       );

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;
  bool get isCompound => hasText && hasImage;
}

@immutable
class CardPointNode {
  final String title;
  final String? imageUrl;
  final int baseRevealStep;
  final List<SubPointData> subPoints;

  const CardPointNode({
    required this.title,
    this.imageUrl,
    required this.baseRevealStep,
    this.subPoints = const [],
  });
}

@immutable
class ProgressiveGridData {
  final String title;
  final int columns;
  final List<CardPointNode> cards;
  final int maxSteps;

  const ProgressiveGridData({
    required this.title,
    required this.columns,
    required this.cards,
    required this.maxSteps,
  });
}