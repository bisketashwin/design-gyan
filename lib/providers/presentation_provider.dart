import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
import '../commons/values.dart';
import 'presentation_state.dart';

final presentationProvider =
    NotifierProvider<PresentationNotifier, PresentationState>(
  PresentationNotifier.new,
);

class PresentationNotifier extends Notifier<PresentationState> {
  Timer? _frictionTimer;
  final int startingStepIndex = 1;

  @override
  PresentationState build() {
    ref.onDispose(() => _frictionTimer?.cancel());
    _loadMarkdownSlides();
    return const PresentationState();
  }

  void toggleFullscreen() {
    if (kIsWeb) {
      final document = web.document;
      if (document.fullscreenElement == null) {
        document.documentElement?.requestFullscreen();
      } else {
        document.exitFullscreen();
      }
    } else {
      // Native state toggle
      state = state.copyWith(isFullscreen: !state.isFullscreen);
      SystemChrome.setEnabledSystemUIMode(
        state.isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    }
  }

  Future<void> _loadMarkdownSlides() async {
    try {
      final String rawMd =
          await rootBundle.loadString('assets/game_design-human-made.md');
      final rawSlides =
          rawMd.replaceAll('\r\n', '\n').split(RegExp(r'\n---\n'));
      final parsedSlides = rawSlides
          .map((s) => SlideData.fromMarkdown(s))
          .where((slide) => slide.title.isNotEmpty || slide.items.isNotEmpty)
          .toList();

      state = state.copyWith(
        slides: parsedSlides,
        isLoading: false,
        visibleStepCount: startingStepIndex,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void nextStep() {
    if (state.currentSlide?.type == SlideType.fullMedia) {
      _handleTerminalStepFriction();
      return;
    }

    if (state.visibleStepCount < state.totalStepCount) {
      final nextStep = state.visibleStepCount + 1;
      final reachedEnd = nextStep >= state.totalStepCount;

      state = state.copyWith(
        visibleStepCount: nextStep,
        isAtSlideEnd:
            reachedEnd && state.currentSlideIndex < state.slides.length - 1,
      );
    } else if (state.currentSlideIndex < state.slides.length - 1) {
      _handleTerminalStepFriction();
    }
  }

  void _handleTerminalStepFriction() {
    final viewportState = ref.read(viewportSettingsProvider);
    final int frictionTimeoutDuration =
        viewportState.isFrictionEnabled ? 500 : 1500;

    if (state.isAtSlideEnd &&
        _frictionTimer != null &&
        _frictionTimer!.isActive) {
      _frictionTimer?.cancel();
      _setCurrentSlideIndex(state.currentSlideIndex + 1);
    } else {
      state = state.copyWith(isAtSlideEnd: true);
      _frictionTimer?.cancel();
      _frictionTimer =
          Timer(Duration(milliseconds: frictionTimeoutDuration), () {
        state = state.copyWith(isAtSlideEnd: false);
      });
    }
  }

  void previousStep() {
    _frictionTimer?.cancel();

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

  void _setCurrentSlideIndex(int newIndex, {int? targetVisibleSteps}) {
    if (newIndex >= 0 && newIndex < state.slides.length) {
      state = state.copyWith(
        currentSlideIndex: newIndex,
        visibleStepCount: targetVisibleSteps ?? startingStepIndex,
        isAtSlideEnd: false,
      );
      onSlideEnter();
    }
  }

  void goToFirst() => _setCurrentSlideIndex(0);

  void goToLast() => _setCurrentSlideIndex(state.slides.length - 1);

  void goToSlide(int index) => _goToSlideFullyRevealed(index);

  void nextSlideDirect() =>
      _goToSlideFullyRevealed(state.currentSlideIndex + 1);

  void previousSlideDirect() =>
      _goToSlideFullyRevealed(state.currentSlideIndex - 1);

  void _goToSlideFullyRevealed(int index) {
    if (index >= 0 && index < state.slides.length) {
      final targetSlide = state.slides[index];
      final totalSteps = _getStepCountForSlide(targetSlide);
      _setCurrentSlideIndex(index, targetVisibleSteps: totalSteps);
    }
  }

  void onSlideEnter() {
    final slide = state.currentSlide;
    if (slide == null) return;

    // Trigger audio playback or other slide-enter side effects here
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    if ((isShiftPressed && key == LogicalKeyboardKey.arrowRight) ||
        key == LogicalKeyboardKey.pageDown) {
      nextSlideDirect();
    } else if ((isShiftPressed && key == LogicalKeyboardKey.arrowLeft) ||
        key == LogicalKeyboardKey.pageUp) {
      previousSlideDirect();
    } else if (key == LogicalKeyboardKey.arrowRight ||
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

  int _getStepCountForSlide(SlideData slide) {
    return 1 +
        (slide.subtitle != null ? 1 : 0) +
        slide.callouts.length +
        slide.items.length +
        slide.gridItems.length;
  }
}