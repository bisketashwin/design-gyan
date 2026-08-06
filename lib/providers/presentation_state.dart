import '../models/slide_data.dart';

class PresentationState {
  final List<SlideData> slides;
  final int currentSlideIndex;
  final int visibleStepCount; // Starts at 0 (Blank)
  final bool isLoading;

  const PresentationState({
    this.slides = const [],
    this.currentSlideIndex = 0,
    this.visibleStepCount = 0,
    this.isLoading = true,
  });

  SlideData? get currentSlide =>
      slides.isNotEmpty && currentSlideIndex < slides.length
          ? slides[currentSlideIndex]
          : null;

  int get headerStepCount {
    if (currentSlide == null) return 0;
    return 1 + (currentSlide!.subtitle != null ? 1 : 0);
  }

  int get totalStepCount {
    if (currentSlide == null) return 0;
    int steps = headerStepCount;
    steps += currentSlide!.callouts.length;
    steps += currentSlide!.items.length;
    steps += currentSlide!.gridItems.length;
    return steps;
  }

  PresentationState copyWith({
    List<SlideData>? slides,
    int? currentSlideIndex,
    int? visibleStepCount,
    bool? isLoading,
  }) {
    return PresentationState(
      slides: slides ?? this.slides,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      visibleStepCount: visibleStepCount ?? this.visibleStepCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}