import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/viewport_settings_state.dart';

class ViewportSettingsNotifier extends Notifier<ViewportSettingsState> {
  static const String _activeKeyPref = 'viewport_active_preset_key';
  static const String _presetListPref = 'viewport_preset_keys_list';
  static const String _presetPrefix = 'viewport_preset_';

  @override
  ViewportSettingsState build() {
    _loadAllFromStorage();
    return const ViewportSettingsState();
  }

  Future<void> _loadAllFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keysList = prefs.getStringList(_presetListPref) ?? [];
    final activeKey = prefs.getString(_activeKeyPref);

    Map<String, ViewportSettingsState> loadedPresets = {};

    for (final key in keysList) {
      final rawJson = prefs.getString('$_presetPrefix$key');
      if (rawJson != null) {
        loadedPresets[key] = ViewportSettingsState.fromJson(jsonDecode(rawJson));
      }
    }

    if (loadedPresets.isNotEmpty) {
      final currentKey = (activeKey != null && loadedPresets.containsKey(activeKey))
          ? activeKey
          : loadedPresets.keys.first;
      final activeState = loadedPresets[currentKey]!;

      state = activeState.copyWith(
        activePresetKey: currentKey,
        savedPresets: loadedPresets,
      );
    }
  }
 // --- Preset Selection ---
  void selectPresetSlot(String key) {
    if (key == 'default') {
      final defaults = ViewportSettingsState.factoryDefaults;
      state = state.copyWith(
        unifiedZoom: defaults.unifiedZoom,
        textScale: defaults.textScale,
        mediaScale: defaults.mediaScale,
        lineHeight: defaults.lineHeight,
        letterSpacing: defaults.letterSpacing,
        activePresetKey: 'default',
        savedPresets: state.savedPresets,
      );
      return;
    }

    if (!state.savedPresets.containsKey(key)) return;
    
    final targetPreset = state.savedPresets[key]!;
    state = state.copyWith(
      unifiedZoom: targetPreset.unifiedZoom,
      textScale: targetPreset.textScale,
      mediaScale: targetPreset.mediaScale,
      lineHeight: targetPreset.lineHeight,
      letterSpacing: targetPreset.letterSpacing,
      activePresetKey: key,
      savedPresets: state.savedPresets,
    );
  }

  // --- Slider Value Handlers (Clear active preset focus on tweak) ---
  void _updateStateWithSliderDelta(ViewportSettingsState newState) {
    // If tweaking away from active preset, unset active preset key
    String? currentKey = state.activePresetKey;
    if (currentKey != null && state.savedPresets.containsKey(currentKey)) {
      if (newState.hasDeltaFrom(state.savedPresets[currentKey]!)) {
        currentKey = null;
      }
    } else if (currentKey == 'default' && newState.hasDeltaFrom(ViewportSettingsState.factoryDefaults)) {
      currentKey = null;
    }

    state = newState.copyWith(
      activePresetKey: currentKey,
      forceNullActivePreset: currentKey == null,
    );
  }

  void setUnifiedZoom(double value) =>
      _updateStateWithSliderDelta(state.copyWith(unifiedZoom: value.clamp(0.7, 1.5)));

  void setTextScale(double value) =>
      _updateStateWithSliderDelta(state.copyWith(textScale: value.clamp(0.8, 1.6)));

  void setMediaScale(double value) =>
      _updateStateWithSliderDelta(state.copyWith(mediaScale: value.clamp(0.7, 1.4)));

  void setLineHeight(double value) =>
      _updateStateWithSliderDelta(state.copyWith(lineHeight: value.clamp(1.0, 1.8)));

  void setLetterSpacing(double value) =>
      _updateStateWithSliderDelta(state.copyWith(letterSpacing: value.clamp(-0.5, 2.0)));
  // --- Individual Slider Resets ---
  void resetUnifiedZoom() {
    final base = _getActiveBase();
    state = state.copyWith(unifiedZoom: base.unifiedZoom);
  }

  void resetTextScale() {
    final base = _getActiveBase();
    state = state.copyWith(textScale: base.textScale);
  }

  void resetMediaScale() {
    final base = _getActiveBase();
    state = state.copyWith(mediaScale: base.mediaScale);
  }

  void resetLineHeight() {
    final base = _getActiveBase();
    state = state.copyWith(lineHeight: base.lineHeight);
  }

  void resetLetterSpacing() {
    final base = _getActiveBase();
    state = state.copyWith(letterSpacing: base.letterSpacing);
  }

  ViewportSettingsState _getActiveBase() {
    if (state.activePresetKey != null &&
        state.savedPresets.containsKey(state.activePresetKey)) {
      return state.savedPresets[state.activePresetKey]!;
    }
    return ViewportSettingsState.factoryDefaults;
  }

  // --- Actions ---
  Future<void> deletePreset(String key) async {
    if (key == 'default') return;

    final prefs = await SharedPreferences.getInstance();
    final updatedPresets = Map<String, ViewportSettingsState>.from(state.savedPresets);
    updatedPresets.remove(key);

    await prefs.remove('$_presetPrefix$key');

    if (updatedPresets.isEmpty || (updatedPresets.length == 1 && updatedPresets.containsKey('default'))) {
      if (updatedPresets.isEmpty) {
        final defaultState = ViewportSettingsState.factoryDefaults.copyWith(
          activePresetKey: 'default',
          savedPresets: {'default': ViewportSettingsState.factoryDefaults},
        );
        
        await prefs.setStringList(_presetListPref, ['default']);
        await prefs.setString(_activeKeyPref, 'default');
        await prefs.setString('${_presetPrefix}default', jsonEncode(defaultState.toJson()));

        state = defaultState;
        return;
      }
    }

    await prefs.setStringList(_presetListPref, updatedPresets.keys.toList());

    final newActiveKey = updatedPresets.containsKey(state.activePresetKey)
        ? state.activePresetKey!
        : updatedPresets.keys.first;

    await prefs.setString(_activeKeyPref, newActiveKey);

    final targetPreset = updatedPresets[newActiveKey]!;
    state = targetPreset.copyWith(
      activePresetKey: newActiveKey,
      savedPresets: updatedPresets,
    );
  }

  void revertToSaved() {
    if (state.activePresetKey != null) {
      selectPresetSlot(state.activePresetKey!);
    } else {
      resetFactoryDefaults();
    }
  }

  void resetFactoryDefaults() {
    state = ViewportSettingsState.factoryDefaults.copyWith(
      activePresetKey: state.activePresetKey ?? 'default',
      savedPresets: state.savedPresets,
    );
  }

  // --- Create New Preset ---
  Future<void> saveNewPreset() async {
    final userPresets = Map<String, ViewportSettingsState>.from(
      state.savedPresets..remove('default'),
    );

    // Limit custom presets to max 3
    if (userPresets.length >= 3) return;

    final newKey = 'preset_${userPresets.length + 1}';
    userPresets[newKey] = state;

    final updatedAll = {'default': ViewportSettingsState.factoryDefaults, ...userPresets};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_presetListPref, updatedAll.keys.toList());
    await prefs.setString(_activeKeyPref, newKey);
    await prefs.setString('$_presetPrefix$newKey', jsonEncode(state.toJson()));

    state = state.copyWith(
      activePresetKey: newKey,
      savedPresets: updatedAll,
    );
  }
}

final viewportSettingsProvider =
    NotifierProvider<ViewportSettingsNotifier, ViewportSettingsState>(
  ViewportSettingsNotifier.new,
);