import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewport_setting_provider.dart';
import '../utils/markdown_formatter.dart';

class CalloutBox extends ConsumerWidget {
  final String calloutText;
  const CalloutBox({
    super.key,
    required this.calloutText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);

    return Container(
      margin: EdgeInsets.only(bottom: 28 * viewport.unifiedZoom),
      padding: EdgeInsets.symmetric(
        horizontal: 22 * viewport.unifiedZoom,
        vertical: 18 * viewport.unifiedZoom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(8 * viewport.unifiedZoom),
        border: Border(
          left: BorderSide(
            color: const Color(0xFFFFB800),
            width: 4 * viewport.unifiedZoom,
          ),
        ),
      ),
      child: RichText(
        text: MarkdownFormatter.parseInline(
          calloutText,
          TextStyle(
            fontSize: baseUiSize * 1.35 * viewport.textScale,
            height: viewport.lineHeight,
            letterSpacing: viewport.letterSpacing,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}