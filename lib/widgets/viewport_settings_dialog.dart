import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ViewportSettingsDialog extends ConsumerWidget {
  const ViewportSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ViewportSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(viewportSettingsProvider);
    final notifier = ref.read(viewportSettingsProvider.notifier);

    return PointerInterceptor(
      child: Dialog(
        backgroundColor: const Color(0xFF121620),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "VIEWPORT & READABILITY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),

              // Unified Zoom Slider
              _buildSliderSection(
                label: "Unified Canvas Zoom",
                valueDisplay: "${(settings.unifiedZoom * 100).round()}%",
                value: settings.unifiedZoom,
                min: 0.7,
                max: 1.5,
                divisions: 16,
                onChanged: notifier.setUnifiedZoom,
              ),

              const SizedBox(height: 16),

              // Text Scale Slider
              _buildSliderSection(
                label: "Text Scale Multiplier",
                valueDisplay: "${settings.textScale.toStringAsFixed(2)}x",
                value: settings.textScale,
                min: 0.8,
                max: 1.6,
                divisions: 16,
                onChanged: notifier.setTextScale,
              ),

              const SizedBox(height: 16),

              // Media Scale Slider
              _buildSliderSection(
                label: "Media Boundary Scale",
                valueDisplay: "${settings.mediaScale.toStringAsFixed(2)}x",
                value: settings.mediaScale,
                min: 0.7,
                max: 1.4,
                divisions: 14,
                onChanged: notifier.setMediaScale,
              ),

              const SizedBox(height: 16),

              // Line Height Slider
              _buildSliderSection(
                label: "Line Height Spacing",
                valueDisplay: settings.lineHeight.toStringAsFixed(2),
                value: settings.lineHeight,
                min: 1.0,
                max: 1.8,
                divisions: 16,
                onChanged: notifier.setLineHeight,
              ),

              const SizedBox(height: 16),

              // Letter Spacing Slider
              _buildSliderSection(
                label: "Letter Spacing",
                valueDisplay: "${settings.letterSpacing.toStringAsFixed(1)}px",
                value: settings.letterSpacing,
                min: -0.5,
                max: 2.0,
                divisions: 25,
                onChanged: notifier.setLetterSpacing,
              ),

              const Divider(color: Colors.white12, height: 32),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                    ),
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text("Reset Defaults"),
                    onPressed: () => notifier.resetDefaults(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection({
    required String label,
    required String valueDisplay,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueDisplay,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF00F0FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFFB800),
            inactiveTrackColor: Colors.white12,
            thumbColor: const Color(0xFFFFB800),
            overlayColor: const Color(0xFFFFB800).withOpacity(0.12),
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