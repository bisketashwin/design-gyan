/// Represents configuration metadata parsed from a slide's directive block
/// (e.g., `<!-- type: progressive-grid:3 aspect-ratio: 1:1 card-width: 15% -->`).
class ProgressiveGridDirectives {
  final int columns;
  final double aspectRatio;
  final double? cardWidthPercent;

  const ProgressiveGridDirectives({
    required this.columns,
    required this.aspectRatio,
    this.cardWidthPercent,
  });

  /// Factory constructor for fallback defaults when no directive comment is present.
  factory ProgressiveGridDirectives.defaults() {
    return const ProgressiveGridDirectives(
      columns: 3,
      aspectRatio: 16 / 9,
      cardWidthPercent: null,
    );
  }

  ProgressiveGridDirectives copyWith({
    int? columns,
    double? aspectRatio,
    double? cardWidthPercent,
  }) {
    return ProgressiveGridDirectives(
      columns: columns ?? this.columns,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      cardWidthPercent: cardWidthPercent ?? this.cardWidthPercent,
    );
  }

  @override
  String toString() {
    return 'ProgressiveGridDirectives(columns: $columns, aspectRatio: $aspectRatio, cardWidthPercent: $cardWidthPercent)';
  }
}