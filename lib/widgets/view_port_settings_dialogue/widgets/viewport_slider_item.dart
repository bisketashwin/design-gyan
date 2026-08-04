import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';

class ViewportSliderItem extends StatelessWidget {
  const ViewportSliderItem({
    super.key,
    required this.label,
    required this.valueDisplay,
    required this.value,
    required this.baseValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.activePresetKey,
    required this.onChanged,
    required this.onResetProperty,
  });

  final String label;
  final String valueDisplay;
  final double value;
  final double baseValue;
  final double min;
  final double max;
  final int divisions;
  final String? activePresetKey;
  final ValueChanged<double> onChanged;
  final VoidCallback onResetProperty;

  @override
  Widget build(BuildContext context) {
    final isModified = (value - baseValue).abs() > 0.001;

    final Color activeColor = switch ((isModified, activePresetKey)) {
      (true, _) => ViewportDialogTheme.editedSettingsColor,
      (false, 'default' || null) => ViewportDialogTheme.defaultSettingsColor,
      _ => ViewportDialogTheme.presetSettingsColor,
    };

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
                      Icons.restart_alt,
                      size: 24,
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
}