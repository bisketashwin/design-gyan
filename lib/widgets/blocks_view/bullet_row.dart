import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/utils/markdown_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulletRow extends ConsumerWidget {
  final String text;
  final bool isVisible;
  final bool withPadding; // false when nested inside a compound Row that already pads
  const BulletRow({super.key, required this.text, required this.isVisible, this.withPadding = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("⚡ ", style: TextStyle(fontSize: baseUiSize * 1.4 * viewport.textScale, color: const Color(0xFFFFB800))),
        Expanded(
          child: RichText(
            text: MarkdownFormatter.parseInline(
              text,
              TextStyle(
                fontSize: baseUiSize * 1.5 * viewport.textScale,
                height: viewport.lineHeight,
                letterSpacing: viewport.letterSpacing,
                color: isVisible ? Colors.white70 : Colors.white24,
              ),
            ),
          ),
        ),
      ],
    );
    if (!withPadding) return row;
    return Padding(padding: EdgeInsets.symmetric(vertical: 10.0 * viewport.unifiedZoom), child: row);
  }
}