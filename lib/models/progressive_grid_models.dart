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
  final double aspectRatio;
  final String? cardWidth;
  final int baseRevealStep;
  final List<SubPointData> subPoints;

  CardPointNode({
    required this.title,
    this.imageUrl,
    required this.aspectRatio,
    this.cardWidth,
    required this.baseRevealStep,
    required this.subPoints,
  });

  CardPointNode copyWith({
    String? title,
    String? imageUrl,
    double? aspectRatio,
    String? cardWidth,
    int? baseRevealStep,
    List<SubPointData>? subPoints,
  }) {
    return CardPointNode(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      cardWidth: cardWidth ?? this.cardWidth,
      baseRevealStep: baseRevealStep ?? this.baseRevealStep,
      subPoints: subPoints ?? this.subPoints,
    );
  }
}

@immutable
class ProgressiveGridData {
  final String title;
  final int columns;
  final List<CardPointNode> cards;
  final double? cardWidthPercent;
  final int maxSteps;

  const ProgressiveGridData({
    required this.title,
    required this.columns,
    required this.cards,
    required this.maxSteps, 
    this.cardWidthPercent,
  });
}