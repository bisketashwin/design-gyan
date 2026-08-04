import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../models/viewport_settings_state.dart';
import '../providers/viewport_setting_provider.dart';

class ViewportSettingsDialog extends ConsumerWidget {
  const ViewportSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ViewportSettingsDialog(),
    );
  }

  String _getPresetLabel(String key) {
    if (key == 'default') return 'Default';
    if (key == 'preset1') return 'Preset 1';
    if (key == 'preset2') return 'Preset 2';
    return key.replaceAll('_', ' ').toUpperCase();
  }

  final editedSettingsColor = const Color(0xFF14BE4D);
  final presetSettingsColor = const Color(0xFFFFB800);
  final defaultSettingsColor = const Color(0xFF718384);
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(viewportSettingsProvider);
    final notifier = ref.read(viewportSettingsProvider.notifier);

    final activeSaved = settings.activePresetKey != null
        ? settings.savedPresets[settings.activePresetKey]
        : null;

    final baseComparison = activeSaved ?? ViewportSettingsState.factoryDefaults;
    final hasDelta = settings.hasDeltaFrom(baseComparison);

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
              const Divider(color: Colors.white12, height: 20),

              // Sliders
              _buildSliderSection(
                label: "Unified Canvas Zoom",
                valueDisplay: "${(settings.unifiedZoom * 100).round()}%",
                value: settings.unifiedZoom,
                baseValue: baseComparison.unifiedZoom,
                min: 0.7,
                max: 1.5,
                divisions: 16,
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
                onChanged: notifier.setTextScale,
                onResetProperty: notifier.resetTextScale,
              ),
              const SizedBox(height: 12),

              _buildSliderSection(
                label: "Media Boundary Scale",
                valueDisplay: "${settings.mediaScale.toStringAsFixed(2)}x",
                value: settings.mediaScale,
                baseValue: baseComparison.mediaScale,
                min: 0.7,
                max: 1.4,
                divisions: 14,
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
                onChanged: notifier.setLetterSpacing,
                onResetProperty: notifier.resetLetterSpacing,
              ),

              // Presets Selection Bar (Hidden when empty)
              const SizedBox(height: 16),
              // Presets Selection Bar
              const SizedBox(height: 16),
              // Presets Row
              const SizedBox(height: 16),
              const Text(
                "PRESETS",
                style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Immutable Default Chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildPresetChip(
                        "Default",
                        'default',
                        settings,
                        notifier,
                      ),
                    ),

                    // User Created Preset Chips
                    ...settings.savedPresets.keys
                        .where((key) => key != 'default')
                        .map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildPresetChip(
                          _getPresetLabel(key),
                          key,
                          settings,
                          notifier,
                        ),
                      );
                    }),

                    // "+ Save Preset" Chip (Active when settings are un-saved to a preset)
                    if (settings.activePresetKey == null) ...[
                      _buildSavePresetChip(
                        onTap: () async {
                          await notifier.saveNewPreset();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 28),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white54),
                    onPressed: () {
                      notifier.revertToSaved();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Done",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              
            ],
          ),
        ),
      ),
    );
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
            color: const Color.fromARGB(255, 20, 190, 77),
            borderRadius: BorderRadius.circular(20),
            // border: Border.all(color: const Color(0xFF10A943), width: 1.0),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: Colors.black),
              SizedBox(width: 4),
              Text(
                "Save Preset",
                style: TextStyle(
                  fontSize: 12,
                  color:Colors.black,
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
  ) {
    final isSelected = settings.activePresetKey == key;
    final isDefault = key == 'default';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFB800) : const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFB800) : Colors.white12,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFFFB800).withOpacity(0.3),
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
                    color: isSelected ? Colors.black : Colors.white70,
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
                        color: isSelected ? Colors.black87 : Colors.white38,
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

  Widget _buildSliderSection({
    required String label,
    required String valueDisplay,
    required double value,
    required double baseValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required VoidCallback onResetProperty,
  }) {
    final isModified = (value - baseValue).abs() > 0.001;

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
                    color: Colors.white70,
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
                      color: Color(0xFF00F0FF),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              valueDisplay,
              style: TextStyle(
                fontSize: 13,
                color: isModified ? const Color(0xFF00F0FF) : Colors.white54,
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