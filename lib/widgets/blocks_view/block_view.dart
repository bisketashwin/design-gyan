import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/blocks_view/bullet_row.dart';
import 'package:design_gyan/widgets/callout_box.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/widgets/inline_media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockView extends ConsumerWidget {
  final Block block;
  final bool isVisible;
  const BlockView({super.key, required this.block, required this.isVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('block text: ${block.text} ---- role ${block.role}');
    final viewport = ref.watch(viewportSettingsProvider);

    if (block.role == BlockRole.callout) {
      return CalloutBox(calloutText: block.text ?? '');
    }

    if (block.role == BlockRole.sectionHeader) {
      return _SectionHeaderText(block: block);
    }

    // BlockRole.bullet from here — may be text-only, image-only, or compound
    if (block.isCompound) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0 * viewport.unifiedZoom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            BulletRow(text: block.text!, isVisible: isVisible, withPadding: false),
            SizedBox(width: 20 * viewport.unifiedZoom),
            InlineMediaWidget(media: _mediaFrom(block), showCaption: false),
            
          ],
        ),
      );
    }
    if (block.hasImage) {
      return InlineMediaWidget(media: _mediaFrom(block));
    }
    return BulletRow(text: block.text ?? '', isVisible: isVisible);
  }

  MediaData _mediaFrom(Block block) {
    final url = block.imageUrl!;
    final isVideo = url.contains('youtube.com') || url.contains('youtu.be');
    return MediaData(
      url: url,
      caption: block.imageCaption ?? '',
      type: isVideo ? MediaType.video : MediaType.image,
      aspectRatio: block.aspectRatio,
      heightPercent: block.heightPercent,
      placement: MediaPlacement.inline,
    );
  }
}

class _SectionHeaderText extends ConsumerWidget {
  final Block block;
  const _SectionHeaderText({required this.block});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0 * viewport.unifiedZoom),
      child: Text(
        block.text ?? '',
        style: TextStyle(
          fontSize: baseUiSize * 1.8 * viewport.textScale,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: viewport.lineHeight,
          letterSpacing: viewport.letterSpacing,
        ),
      ),
    );
  }
}