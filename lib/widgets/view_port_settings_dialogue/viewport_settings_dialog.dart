import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/build_footer.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/build_header.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/build_presets_row.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/build_sliders.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
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

    final activeSaved = settings.activePresetKey != null
        ? settings.savedPresets[settings.activePresetKey]
        : null;

    final baseComparison = activeSaved ?? ViewportSettingsState.factoryDefaults;

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
              // Header
              buildHeader(context, notifier),
              const Divider(color: ViewportDialogTheme.dividerColor, height: 20),

              // Sliders
              ...buildSliderUi(settings, notifier, baseComparison),

              // Presets Row
              const SizedBox(height: 16),
              ...buildPresetsRow(settings, notifier, baseComparison),

              const Divider(color: ViewportDialogTheme.dividerColor, height: 28),

              // Footer Actions
              buildFotterActions(context, notifier),
            ],
          ),
        ),
      ),
    );
  }

}