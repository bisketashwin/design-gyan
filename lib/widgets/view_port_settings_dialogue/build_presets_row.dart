import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';

  String _getPresetLabel(String key) {
    if (key == 'default') return 'Default';
    if (key == 'preset1') return 'Preset 1';
    if (key == 'preset2') return 'Preset 2';
    return key.replaceAll('_', ' ').toUpperCase();
  }

  List<Widget> buildPresetsRow(
    ViewportSettingsState settings,
    ViewportSettingsNotifier notifier,
    ViewportSettingsState baseComparison,
  ) {
    // Check if any property differs from the active baseline state
    final isDirty = (settings.unifiedZoom - baseComparison.unifiedZoom).abs() > 0.001 ||
        (settings.textScale - baseComparison.textScale).abs() > 0.001 ||
        (settings.mediaScale - baseComparison.baseValueMediaScale).abs() > 0.001 ||
        (settings.lineHeight - baseComparison.lineHeight).abs() > 0.001 ||
        (settings.letterSpacing - baseComparison.letterSpacing).abs() > 0.001;

    return [
      const Text(
        "PRESETS",
        style: TextStyle(
          fontSize: 11,
          color: ViewportDialogTheme.textMuted,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Immutable Default Chip
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildPresetChip("Default", 'default', settings, notifier, isDirty),
            ),

            // User Created Preset Chips
            ...settings.savedPresets.keys.where((key) => key != 'default').map((key) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildPresetChip(
                  _getPresetLabel(key),
                  key,
                  settings,
                  notifier,
                  isDirty,
                ),
              );
            }),

            // "+ Save Preset" Chip (Appears whenever settings are tweaked away from active preset)
            if (isDirty) ...[
              _buildSavePresetChip(
                onTap: () async {
                  await notifier.saveNewPreset();
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildSavePresetChip({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ViewportDialogTheme.editedSettingsColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: ViewportDialogTheme.textOnAccent),
              SizedBox(width: 4),
              Text(
                "Save Preset",
                style: TextStyle(
                  fontSize: 12,
                  color: ViewportDialogTheme.textOnAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    String label,
    String key,
    ViewportSettingsState settings,
    ViewportSettingsNotifier notifier,
    bool isDirty,
  ) {
    // Default chip is selected if activePresetKey is 'default' OR on clean start where activePresetKey is null
    final isDefault = key == 'default';
    final isSelected = settings.activePresetKey == key || (isDefault && settings.activePresetKey == null && !isDirty);

    final activeColor = isDefault
        ? ViewportDialogTheme.defaultSettingsColor
        : ViewportDialogTheme.presetSettingsColor;

    final backgroundColor = isSelected
        ? activeColor
        : ViewportDialogTheme.chipBackground;

    final borderColor = isSelected
        ? activeColor
        : ViewportDialogTheme.borderSubtle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            notifier.selectPresetSlot(key);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: isDefault ? 12 : 8,
              top: 6,
              bottom: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? ViewportDialogTheme.textOnAccent
                        : ViewportDialogTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                if (!isDefault) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      notifier.deletePreset(key);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: isSelected
                            ? ViewportDialogTheme.textOnAccent
                            : ViewportDialogTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }