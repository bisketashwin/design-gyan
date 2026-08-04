import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'widgets/dialog_footer.dart';
import 'widgets/dialog_header.dart';
import 'widgets/preset_selector_row.dart';
import 'widgets/viewport_slider_item.dart';

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
    final baseComparison = notifier.activeBaseComparison;

    return PointerInterceptor(
      child: Dialog(
        backgroundColor: ViewportDialogTheme.dialogBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ViewportDialogTheme.borderSubtle),
        ),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DialogHeader(),
              const Divider(color: ViewportDialogTheme.dividerColor, height: 20),
              ViewportSliderItem(
                label: "Unified Canvas Zoom",
                valueDisplay: settings.formattedZoom,
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
              ViewportSliderItem(
                label: "Text Scale Multiplier",
                valueDisplay: settings.formattedTextScale,
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
              ViewportSliderItem(
                label: "Media Boundary Scale",
                valueDisplay: settings.formattedMediaScale,
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
              ViewportSliderItem(
                label: "Line Height Spacing",
                valueDisplay: settings.formattedLineHeight,
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
              ViewportSliderItem(
                label: "Letter Spacing",
                valueDisplay: settings.formattedLetterSpacing,
                value: settings.letterSpacing,
                baseValue: baseComparison.letterSpacing,
                min: -0.5,
                max: 2.0,
                divisions: 25,
                activePresetKey: settings.activePresetKey,
                onChanged: notifier.setLetterSpacing,
                onResetProperty: notifier.resetLetterSpacing,
              ),
              const SizedBox(height: 16),
              const PresetSelectorRow(),
              const Divider(color: ViewportDialogTheme.dividerColor, height: 28),
              DialogFooter(notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }
}