import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
import '../commons/values.dart';
import 'presentation_state.dart';

final presentationProvider =
    NotifierProvider<PresentationNotifier, PresentationState>(
  PresentationNotifier.new,
);

class PresentationNotifier extends Notifier<PresentationState> {
  @override
  PresentationState build() {
    _loadMarkdownSlides();
    return const PresentationState();
  }

  Future<void> _loadMarkdownSlides() async {
    try {
      final String rawMd = await rootBundle.loadString('assets/game_design-human-made.md');
      final rawSlides = rawMd.replaceAll('\r\n', '\n').split(RegExp(r'\n---\n'));
      final parsedSlides = rawSlides
          .map((s) => SlideData.fromMarkdown(s))
          .where((slide) => slide.title.isNotEmpty || slide.items.isNotEmpty)
          .toList();
      state = state.copyWith(
        slides: parsedSlides,
        isLoading: false,
        visibleStepCount: 0,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // lib/providers/presentation_provider.dart
  void nextStep() {
    if (state.currentSlide?.type == SlideType.fullMedia) {
      if (!state.isAtSlideEnd && state.currentSlideIndex < state.slides.length - 1) {
        state = state.copyWith(isAtSlideEnd: true);
        return;
      }
      nextSlideDirect();
      return;
    }

    // Phase 1: Reveal steps inside slide
    if (state.visibleStepCount < state.totalStepCount) {
      final nextStep = state.visibleStepCount + 1;
      final reachedEnd = nextStep >= state.totalStepCount;
      state = state.copyWith(
        visibleStepCount: nextStep,
        isAtSlideEnd: reachedEnd && state.currentSlideIndex < state.slides.length - 1,
      );
    } 
    // Phase 2: Friction barrier check
    else if (!state.isAtSlideEnd && state.currentSlideIndex < state.slides.length - 1) {
      state = state.copyWith(isAtSlideEnd: true);
    } 
    // Phase 3: Transition to next slide
    else if (state.currentSlideIndex < state.slides.length - 1) {
      _setCurrentSlideIndex(state.currentSlideIndex + 1);
    }
  }

  void previousStep() {
    if (state.isAtSlideEnd) {
      state = state.copyWith(isAtSlideEnd: false);
      return;
    }
    
    if (state.currentSlide?.type == SlideType.fullMedia) {
      previousSlideDirect();
      return;
    }

    if (state.visibleStepCount > 1) {
      state = state.copyWith(visibleStepCount: state.visibleStepCount - 1);
    } else if (state.currentSlideIndex > 0) {
      _setCurrentSlideIndex(state.currentSlideIndex - 1);
    }
  }

  void _setCurrentSlideIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < state.slides.length) {
      state = state.copyWith(
        currentSlideIndex: newIndex,
        visibleStepCount: 0,
        isAtSlideEnd: false, // Reset friction indicator
      );
      onSlideEnter();
    }
  }

  void goToFirst() {
    state = state.copyWith(currentSlideIndex: 0, visibleStepCount: 0);
  }

  void goToLast() {
    state = state.copyWith(
      currentSlideIndex: state.slides.length - 1,
      visibleStepCount: 0,
    );
  }

  void goToSlide(int index) {
    _setCurrentSlideIndex(index);
  }

  void nextSlideDirect() {
    if (state.currentSlideIndex < state.slides.length - 1) {
      _setCurrentSlideIndex(state.currentSlideIndex + 1);
    }
  }

  void previousSlideDirect() {
    if (state.currentSlideIndex > 0) {
      _setCurrentSlideIndex(state.currentSlideIndex - 1);
    }
  }

  void onSlideEnter() {
    final slide = state.currentSlide;
    if (slide == null) return;

    // 1. Only auto-reveal step 1 if it's a standard slide with steps to show
    if (slide.type == SlideType.standard && state.totalStepCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.visibleStepCount == 0) {
          state = state.copyWith(visibleStepCount: 1);
        }
      }); 
    }

    // Play audio or execute slide actions cleanly for ALL slides
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      if ((isShiftPressed && key == LogicalKeyboardKey.arrowRight) ||
          key == LogicalKeyboardKey.pageDown) {
        nextSlideDirect();
        return;
      }
      if ((isShiftPressed && key == LogicalKeyboardKey.arrowLeft) ||
          key == LogicalKeyboardKey.pageUp) {
        previousSlideDirect();
        return;
      }
      if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.space) {
        nextStep();
      } else if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.backspace) {
        previousStep();
      } else if (key == LogicalKeyboardKey.home) {
        goToFirst();
      } else if (key == LogicalKeyboardKey.end) {
        goToLast();
      }
    }
  }
}