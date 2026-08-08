import 'package:design_gyan/commons/values.dart';

import '../models/slide_data.dart';
class PresentationState {
  final List<SlideData> slides;
  final int currentSlideIndex;
  final int visibleStepCount; // Starts at 0 (Blank)
  final bool isLoading;
  final bool isAtSlideEnd;
  final bool isFullscreen;

  const PresentationState({
    this.slides = const [],
    this.currentSlideIndex = 0,
    this.visibleStepCount = 0,
    this.isLoading = true,
    this.isAtSlideEnd = false,
    this.isFullscreen = false,
  });

  SlideData? get currentSlide =>
      slides.isNotEmpty && currentSlideIndex < slides.length
          ? slides[currentSlideIndex]
          : null;

  int get headerStepCount {
    if (currentSlide == null) return 0;
    return 1 + (currentSlide!.subtitle != null ? 1 : 0);
  }

  int get totalStepCount => currentSlide?.totalStepCount ?? 0;

  bool get isFullyRevealed => visibleStepCount >= totalStepCount;

  PresentationState copyWith({
    List<SlideData>? slides,
    int? currentSlideIndex,
    int? visibleStepCount,
    bool? isAtSlideEnd,
    bool? isLoading,
    bool? isFullscreen,
  }) {
    return PresentationState(
      slides: slides ?? this.slides,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      visibleStepCount: visibleStepCount ?? this.visibleStepCount,
      isAtSlideEnd: isAtSlideEnd ?? this.isAtSlideEnd,
      isLoading: isLoading ?? this.isLoading,
      isFullscreen: isFullscreen ?? this.isFullscreen,
    );
  }
}