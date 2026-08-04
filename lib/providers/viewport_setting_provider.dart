
import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewportSettingsNotifier extends Notifier<ViewportSettingsState> {
  @override
  ViewportSettingsState build() => const ViewportSettingsState();

  void setUnifiedZoom(double value) {
    state = state.copyWith(unifiedZoom: value.clamp(0.7, 1.5));
  }

  void setTextScale(double value) {
    state = state.copyWith(textScale: value.clamp(0.8, 1.6));
  }

  void setMediaScale(double value) {
    state = state.copyWith(mediaScale: value.clamp(0.7, 1.4));
  }

  void setLineHeight(double value) {
    state = state.copyWith(lineHeight: value.clamp(1.0, 1.8));
  }

  void setLetterSpacing(double value) {
    state = state.copyWith(letterSpacing: value.clamp(-0.5, 2.0));
  }

  void resetDefaults() {
    state = const ViewportSettingsState();
  }
}

final viewportSettingsProvider =
    NotifierProvider<ViewportSettingsNotifier, ViewportSettingsState>(
  ViewportSettingsNotifier.new,
);