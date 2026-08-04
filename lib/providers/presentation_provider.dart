// lib/providers/presentation_provider.dart

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
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
      final String rawMd = await rootBundle.loadString('assets/game_design.md');
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

  void nextStep() {
    if (state.visibleStepCount < state.totalStepCount) {
      state = state.copyWith(visibleStepCount: state.visibleStepCount + 1);
    } else if (state.currentSlideIndex < state.slides.length - 1) {
      state = state.copyWith(
        currentSlideIndex: state.currentSlideIndex + 1,
        visibleStepCount: 0,
      );
    }
  }

  void previousStep() {
    if (state.visibleStepCount > 0) {
      state = state.copyWith(visibleStepCount: state.visibleStepCount - 1);
    } else if (state.currentSlideIndex > 0) {
      final prevIndex = state.currentSlideIndex - 1;
      final prevState = state.copyWith(currentSlideIndex: prevIndex);
      state = state.copyWith(
        currentSlideIndex: prevIndex,
        visibleStepCount: prevState.totalStepCount,
      );
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
    if (index >= 0 && index < state.slides.length) {
      state = state.copyWith(
        currentSlideIndex: index,
        visibleStepCount: 0,
      );
    }
  }

  void nextSlideDirect() {
    if (state.currentSlideIndex < state.slides.length - 1) {
      goToSlide(state.currentSlideIndex + 1);
    }
  }

  void previousSlideDirect() {
    if (state.currentSlideIndex > 0) {
      goToSlide(state.currentSlideIndex - 1);
    }
  }

  // Modern Flutter 3.18+ KeyEvent implementation
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