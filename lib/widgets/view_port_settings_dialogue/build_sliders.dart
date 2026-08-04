import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';

  
  List<Widget> buildSliderUi(
    ViewportSettingsState settings,
    ViewportSettingsNotifier notifier,
    ViewportSettingsState baseComparison,
  ) {
    return [
      _buildSliderSection(
        label: "Unified Canvas Zoom",
        valueDisplay: "${(settings.unifiedZoom * 100).round()}%",
        value: settings.unifiedZoom,
        baseValue: baseComparison.unifiedZoom,
        min: 0.7,
        max: 1.5,
        divisions: 16,
        activePresetKey: settings.activePresetKey,
        onChanged: notifier.setUnifiedZoom,
        onResetProperty: notifier.resetUnifiedZoom,
      ),
      const SizedBox(height: 12),

      _buildSliderSection(
        label: "Text Scale Multiplier",
        valueDisplay: "${settings.textScale.toStringAsFixed(2)}x",
        value: settings.textScale,
        baseValue: baseComparison.textScale,
        min: 0.8,
        max: 1.6,
        divisions: 16,
        activePresetKey: settings.activePresetKey,
        onChanged: notifier.setTextScale,
        onResetProperty: notifier.resetTextScale,
      ),
      const SizedBox(height: 12),

      _buildSliderSection(
        label: "Media Boundary Scale",
        valueDisplay: "${settings.mediaScale.toStringAsFixed(2)}x",
        value: settings.mediaScale,
        baseValue: baseComparison.baseValueMediaScale,
        min: 0.7,
        max: 1.4,
        divisions: 14,
        activePresetKey: settings.activePresetKey,
        onChanged: notifier.setMediaScale,
        onResetProperty: notifier.resetMediaScale,
      ),
      const SizedBox(height: 12),

      _buildSliderSection(
        label: "Line Height Spacing",
        valueDisplay: settings.lineHeight.toStringAsFixed(2),
        value: settings.lineHeight,
        baseValue: baseComparison.lineHeight,
        min: 1.0,
        max: 1.8,
        divisions: 16,
        activePresetKey: settings.activePresetKey,
        onChanged: notifier.setLineHeight,
        onResetProperty: notifier.resetLineHeight,
      ),
      const SizedBox(height: 12),

      _buildSliderSection(
        label: "Letter Spacing",
        valueDisplay: "${settings.letterSpacing.toStringAsFixed(1)}px",
        value: settings.letterSpacing,
        baseValue: baseComparison.letterSpacing,
        min: -0.5,
        max: 2.0,
        divisions: 25,
        activePresetKey: settings.activePresetKey,
        onChanged: notifier.setLetterSpacing,
        onResetProperty: notifier.resetLetterSpacing,
      ),
    ];
  }
Widget _buildSliderSection({
    required String label,
    required String valueDisplay,
    required double value,
    required double baseValue,
    required double min,
    required double max,
    required int divisions,
    required String? activePresetKey,
    required ValueChanged<double> onChanged,
    required VoidCallback onResetProperty,
  }) {
    final isModified = (value - baseValue).abs() > 0.001;

    // --- Strict Per-Property Color Resolution ---
    final Color activeColor;
    if (isModified) {
      // ONLY the specific slider that was modified turns Green
      activeColor = ViewportDialogTheme.editedSettingsColor;
    } else if (activePresetKey == 'default' || activePresetKey == null) {
      // Unmodified properties when off-preset or on Default go Greyish
      activeColor = ViewportDialogTheme.defaultSettingsColor;
    } else {
      // Unmodified properties attached to a saved custom preset stay Amber
      activeColor = ViewportDialogTheme.presetSettingsColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ViewportDialogTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isModified) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onResetProperty,
                    child: const Icon(
                      Icons.undo,
                      size: 14,
                      color: ViewportDialogTheme.editedSettingsColor,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              valueDisplay,
              style: TextStyle(
                fontSize: 13,
                color: activeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: ViewportDialogTheme.sliderInactiveTrack,
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.12),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }