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

  String formatPresetLabel(String key) {
    if (key == 'default') return 'Default';
    if (key.startsWith('preset_')) {
      final timestampStr = key.replaceFirst('preset_', '');
      final timestamp = int.tryParse(timestampStr);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return 'Preset ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }
    return key;
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

  ViewportSettingsState get activeBaseComparison {
  if (state.activePresetKey != null &&
      state.savedPresets.containsKey(state.activePresetKey)) {
    return state.savedPresets[state.activePresetKey]!;
  }
  return state.savedPresets['default'] ?? ViewportSettingsState.factoryDefaults;
}

/// Computes whether current UI settings differ from the active baseline.
bool get isDirty => state.hasDeltaFrom(activeBaseComparison);

  // --- Create New Preset ---
  Future<void> saveNewPreset() async {
    final newKey = 'preset_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create a mutable copy of the existing map
    final updatedPresets = Map<String, ViewportSettingsState>.from(
      state.savedPresets,
    );

    // 2. Perform your modifications on the copied map
    updatedPresets[newKey] = ViewportSettingsState(
      unifiedZoom: state.unifiedZoom,
      textScale: state.textScale,
      mediaScale: state.mediaScale,
      lineHeight: state.lineHeight,
      letterSpacing: state.letterSpacing,
    );

    // 3. Emit the updated state with the new map instance
    state = state.copyWith(
      savedPresets: Map.unmodifiable(
        updatedPresets,
      ), // keep it immutable in state
      activePresetKey: newKey,
    );

    // 4. Persist to storage if applicable (SharedPreferences / Hive)
    await _persistPresets(updatedPresets);
  }

  Future<void> _persistPresets(
    Map<String, ViewportSettingsState> presets,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final keysList = presets.keys.toList();

    // Save key registry and current active key
    await prefs.setStringList(_presetListPref, keysList);
    if (state.activePresetKey != null) {
      await prefs.setString(_activeKeyPref, state.activePresetKey!);
    }

    // Save each preset entry as serialized JSON
    for (final entry in presets.entries) {
      await prefs.setString(
        '$_presetPrefix${entry.key}',
        jsonEncode(entry.value.toJson()),
      );
    }
  }
}

final viewportSettingsProvider =
    NotifierProvider<ViewportSettingsNotifier, ViewportSettingsState>(
  ViewportSettingsNotifier.new,
);