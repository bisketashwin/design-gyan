
  import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';

Widget buildHeader(BuildContext context, ViewportSettingsNotifier notifier) {
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