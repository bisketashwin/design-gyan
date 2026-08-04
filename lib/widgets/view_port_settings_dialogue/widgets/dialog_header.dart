import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "VIEWPORT & READABILITY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: ViewportDialogTheme.presetSettingsColor,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            color: ViewportDialogTheme.textDisabled,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}