import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/models/viewport_settings_state.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../callout_box.dart';
import 'inline_media_widget.dart';

class SlideRenderer extends ConsumerWidget {
  final SlideData slide;

  const SlideRenderer({super.key, required this.slide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final screenSize = MediaQuery.sizeOf(context);
    final baseUiSize = viewport.getBaseUiSize(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 48.0 * viewport.unifiedZoom,
        vertical: 32.0 * viewport.unifiedZoom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...slide.blocks.map((block) {
            if (block is TextBlockData) {
              return _buildTextBlock(block, viewport, baseUiSize);
            } else if (block is MediaBlockData) {
              return InlineMediaWidget(media: block.media);
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 100 * viewport.unifiedZoom), // Footer clearance
        ],
      ),
    );
  }

  Widget _buildTextBlock(TextBlockData block, ViewportSettingsState viewport, double baseUiSize) {
    if (block.isHeader) {
      return Padding(
        padding: EdgeInsets.only(bottom: 24.0 * viewport.unifiedZoom),
        child: Text(
          block.text.toUpperCase(),
          style: TextStyle(
            fontSize: baseUiSize * 2.2 * viewport.textScale,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFB800),
            height: viewport.lineHeight,
            letterSpacing: (1.5 * viewport.unifiedZoom) + viewport.letterSpacing,
          ),
        ),
      );
    }
    if (block.isSubheader) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.0 * viewport.unifiedZoom),
        child: Text(
          block.text,
          style: TextStyle(
            fontSize: baseUiSize * 1.4 * viewport.textScale,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF00F0FF),
            height: viewport.lineHeight,
            letterSpacing: viewport.letterSpacing,
          ),
        ),
      );
    }
    if (block.isListItem) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0 * viewport.unifiedZoom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⚡ ",
              style: TextStyle(
                fontSize: baseUiSize * 1.2 * viewport.textScale,
                color: const Color(0xFFFFB800),
              ),
            ),
            Expanded(
              child: Text(
                block.text,
                style: TextStyle(
                  fontSize: baseUiSize * 1.2 * viewport.textScale,
                  color: Colors.white70,
                  height: viewport.lineHeight,
                  letterSpacing: viewport.letterSpacing,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (block.isCallout) {
      return CalloutBox(calloutText: block.text);
    }
    return const SizedBox.shrink();
  }
}