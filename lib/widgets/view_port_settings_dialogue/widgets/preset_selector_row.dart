import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/dialogue_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresetSelectorRow extends ConsumerWidget {
  const PresetSelectorRow({super.key});

  static const int maxPresets = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(viewportSettingsProvider);
    final notifier = ref.read(viewportSettingsProvider.notifier);
    final isDirty = notifier.isDirty;

    final customPresetKeys = settings.savedPresets.keys
        .where((k) => k != 'default')
        .toList();

    final isAtLimit = customPresetKeys.length >= maxPresets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "PRESETS",
              style: TextStyle(
                fontSize: 11,
                color: ViewportDialogTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            if (isDirty && isAtLimit) ...[
              const SizedBox(width: 10),
              Text(
                "• Delete a preset to save changes",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _PresetChip(
                  label: "Default",
                  presetKey: 'default',
                  isSelected: settings.activePresetKey == 'default' ||
                      (settings.activePresetKey == null && !isDirty),
                  onTap: () => notifier.selectPresetSlot('default'),
                ),
              ),
              ...List.generate(customPresetKeys.length, (index) {
                final key = customPresetKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _PresetChip(
                    label: "Preset ${index + 1}",
                    presetKey: key,
                    isSelected: settings.activePresetKey == key,
                    onTap: () => notifier.selectPresetSlot(key),
                    onDelete: () => notifier.deletePreset(key),
                  ),
                );
              }),
              if (isDirty && !isAtLimit)
                _SavePresetChip(onTap: notifier.saveNewPreset),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.presetKey,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  final String label;
  final String presetKey;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDefault = presetKey == 'default';
    final activeColor = isDefault
        ? ViewportDialogTheme.defaultSettingsColor
        : ViewportDialogTheme.presetSettingsColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? activeColor : ViewportDialogTheme.chipBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? activeColor : ViewportDialogTheme.borderSubtle,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
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
                  ),
                ),
                if (!isDefault && onDelete != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: isSelected
                          ? ViewportDialogTheme.textOnAccent
                          : ViewportDialogTheme.textMuted,
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
}

class _SavePresetChip extends StatelessWidget {
  const _SavePresetChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}