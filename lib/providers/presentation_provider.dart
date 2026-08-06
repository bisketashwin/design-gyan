import 'dart:async';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
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
  Timer? _frictionTimer;
  int startingStepIndex = 1; // 0 if you want slide to be bank on evvery slide start with next arrow or space bar usage
  @override
  PresentationState build() {
    ref.onDispose(() {
      _frictionTimer?.cancel();
    });
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

  // Phase 1: Reveal internal items
  if (state.visibleStepCount < state.totalStepCount) {
    final nextStep = state.visibleStepCount + 1;
    final reachedEnd = nextStep >= state.totalStepCount;
    
    state = state.copyWith(
      visibleStepCount: nextStep,
      // If we just revealed the final item, immediately prompt the visual friction indicator
      isAtSlideEnd: reachedEnd && state.currentSlideIndex < state.slides.length - 1,
    );
  } 
  // Phase 2: Slide is already fully revealed; enforce double-press gate
  else if (state.currentSlideIndex < state.slides.length - 1) {
    _handleTerminalStepFriction();
  }
}

  void _handleTerminalStepFriction() {
    final viewportState = ref.read(viewportSettingsProvider);
    // Enabled = 500ms (requires double-click to advance)
    // Disabled = 1500ms (single click gives ample window to advance)
    final int frictionTimeoutDuration = viewportState.isFrictionEnabled ? 500 : 1500;

    if (state.isAtSlideEnd && _frictionTimer != null && _frictionTimer!.isActive) {
      _frictionTimer?.cancel();
      _setCurrentSlideIndex(state.currentSlideIndex + 1);
    } else {
      state = state.copyWith(isAtSlideEnd: true);
      _frictionTimer?.cancel();
      _frictionTimer = Timer(Duration(milliseconds: frictionTimeoutDuration), () {
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

  void _setCurrentSlideIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < state.slides.length) {
      state = state.copyWith(
        currentSlideIndex: newIndex,
        visibleStepCount: startingStepIndex,
        isAtSlideEnd: false, // Reset friction indicator
      );
      onSlideEnter();
    }
  }

  void goToFirst() {
    state = state.copyWith(currentSlideIndex: 0, visibleStepCount: startingStepIndex);
  }

  void goToLast() {
    state = state.copyWith(
      currentSlideIndex: state.slides.length - 1,
      visibleStepCount: startingStepIndex,
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
      final targetIndex = state.currentSlideIndex - 1;
      final targetSlide = state.slides[targetIndex];
      
      // Calculate total steps for the previous slide to fully reveal it
      final totalSteps = _getStepCountForSlide(targetSlide);

      state = state.copyWith(
        currentSlideIndex: targetIndex,
        visibleStepCount: totalSteps,
        isAtSlideEnd: false,
      );
    }
  }

  void onSlideEnter() {
    final slide = state.currentSlide;
    if (slide == null) return;

    // 1. Only auto-reveal step 1 if it's a standard slide with steps to show
    if (slide.type == SlideType.standard && state.totalStepCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.visibleStepCount == 0) {
          state = state.copyWith(visibleStepCount: startingStepIndex);
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

  int _getStepCountForSlide(SlideData slide) {
    int headerSteps = 1 + (slide.subtitle != null ? 1 : 0);
    int steps = headerSteps;
    steps += slide.callouts.length;
    steps += slide.items.length;
    steps += slide.gridItems.length;
    return steps;
  }
}