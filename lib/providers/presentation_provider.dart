import 'dart:async';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
import '../commons/values.dart';
import 'presentation_state.dart';


final presentationProvider =
    AsyncNotifierProvider<PresentationNotifier, PresentationState>(
  PresentationNotifier.new,
);

class PresentationNotifier extends AsyncNotifier<PresentationState> {
  Timer? _frictionTimer;
  final int startingStepIndex = 1;

  @override
  Future<PresentationState> build() async {
    ref.onDispose(() => _frictionTimer?.cancel());

    final slides = await _loadMarkdownSlides();

    return PresentationState(
      slides: slides,
      isLoading: false,
      visibleStepCount: startingStepIndex,
    );
  }

  /// Helper to safely retrieve current PresentationState from AsyncValue
  PresentationState? get _currentState => state.asData?.value;

  /// Helper to safely update PresentationState
  void _updateState(PresentationState Function(PresentationState current) transform) {
    final current = _currentState;
    if (current == null) return;
    state = AsyncData(transform(current));
  }

  Future<List<SlideData>> _loadMarkdownSlides() async {
    try {
      final String rawMd =
          await rootBundle.loadString('assets/game_design-human-made.md');
      final rawSlides =
          rawMd.replaceAll('\r\n', '\n').split(RegExp(r'\n---\n'));
      final parsedSlides = rawSlides
          .map((s) => SlideData.fromMarkdown(s))
          .where((slide) => slide.title.isNotEmpty || slide.items.isNotEmpty)
          .toList();

      List<SlideType> slideTypes = parsedSlides.map((s) => s.type).toList();
      print('slideTypes ${slideTypes.toString()}');

      return parsedSlides;
    } catch (e) {
      print('Failed to load slides: $e');
      return [];
    }
  }

  void toggleFullscreen() {
    final s = _currentState;
    if (s == null) return;

    final newFullscreenState = !s.isFullscreen;

    _updateState((current) => current.copyWith(isFullscreen: newFullscreenState));

    SystemChrome.setEnabledSystemUIMode(
      newFullscreenState ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void nextStep() {
    final s = _currentState;
    if (s == null) return;

    if (s.currentSlide?.type == SlideType.fullMedia) {
      _handleTerminalStepFriction();
      return;
    }

    if (s.visibleStepCount < s.totalStepCount) {
      final nextStepIndex = s.visibleStepCount + 1;
      final reachedEnd = nextStepIndex >= s.totalStepCount;

      _updateState((current) => current.copyWith(
            visibleStepCount: nextStepIndex,
            isAtSlideEnd:
                reachedEnd && current.currentSlideIndex < current.slides.length - 1,
          ));
    } else if (s.currentSlideIndex < s.slides.length - 1) {
      _handleTerminalStepFriction();
    }
  }

  void _handleTerminalStepFriction() {
    final s = _currentState;
    if (s == null) return;

    final viewportState = ref.read(viewportSettingsProvider);
    final int frictionTimeoutDuration =
        viewportState.isFrictionEnabled ? 500 : 1500;

    if (s.isAtSlideEnd &&
        _frictionTimer != null &&
        _frictionTimer!.isActive) {
      _frictionTimer?.cancel();
      _setCurrentSlideIndex(s.currentSlideIndex + 1);
    } else {
      _updateState((current) => current.copyWith(isAtSlideEnd: true));
      _frictionTimer?.cancel();
      _frictionTimer =
          Timer(Duration(milliseconds: frictionTimeoutDuration), () {
        _updateState((current) => current.copyWith(isAtSlideEnd: false));
      });
    }
  }

  void previousStep() {
    final s = _currentState;
    if (s == null) return;

    _frictionTimer?.cancel();

    if (s.isAtSlideEnd) {
      _updateState((current) => current.copyWith(isAtSlideEnd: false));
      return;
    }

    if (s.currentSlide?.type == SlideType.fullMedia) {
      previousSlideDirect();
      return;
    }

    if (s.visibleStepCount > 1) {
      _updateState((current) => current.copyWith(visibleStepCount: current.visibleStepCount - 1));
    } else if (s.currentSlideIndex > 0) {
      _setCurrentSlideIndex(s.currentSlideIndex - 1);
    }
  }

  void _setCurrentSlideIndex(int newIndex, {int? targetVisibleSteps}) {
    final s = _currentState;
    if (s == null) return;

    if (newIndex >= 0 && newIndex < s.slides.length) {
      _updateState((current) => current.copyWith(
            currentSlideIndex: newIndex,
            visibleStepCount: targetVisibleSteps ?? startingStepIndex,
            isAtSlideEnd: false,
          ));
      onSlideEnter();
    }
  }

  void goToFirst() => _setCurrentSlideIndex(0);

  void goToLast() {
    final s = _currentState;
    if (s != null && s.slides.isNotEmpty) {
      _setCurrentSlideIndex(s.slides.length - 1);
    }
  }

  void goToSlide(int index) => _goToSlideFullyRevealed(index);

void nextSlideDirect() {
  final s = _currentState;
  if (s != null && s.currentSlideIndex < s.slides.length - 1) {
    _setCurrentSlideIndex(s.currentSlideIndex + 1);
  }
}

void previousSlideDirect() {
  final s = _currentState;
  if (s != null && s.currentSlideIndex > 0) {
    _setCurrentSlideIndex(s.currentSlideIndex - 1);
  }
}

void _goToSlideFullyRevealed(int index) {
  final s = _currentState;
  if (s == null) return;
  if (index >= 0 && index < s.slides.length) {
    final targetSlide = s.slides[index];
    _setCurrentSlideIndex(
      index,
      targetVisibleSteps: targetSlide.totalStepCount,
    );
  }
}

  

  void onSlideEnter() {
    final s = _currentState;
    if (s?.currentSlide == null) return;

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
}