import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';
import '../../../providers/viewport_setting_provider.dart';

class DialogFooter extends StatelessWidget {
  const DialogFooter({
    super.key,
    required this.notifier,
  });

  final ViewportSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: ViewportDialogTheme.textDisabled,
          ),
          onPressed: () {
            notifier.revertToSaved();
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ViewportDialogTheme.presetSettingsColor,
            foregroundColor: ViewportDialogTheme.textOnAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
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
    );
  }
}