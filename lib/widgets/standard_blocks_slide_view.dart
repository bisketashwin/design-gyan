import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:design_gyan/widgets/blocks_view/block_header_text.dart';
import 'package:design_gyan/widgets/blocks_view/standard_blocks_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandardBlocksSlideView extends ConsumerWidget {
  final SlideData slide;
  final int visibleStepCount;
  const StandardBlocksSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("standard block rendering------------------");
    final viewport = ref.watch(viewportSettingsProvider);

    final headerBlocks = slide.contentBlocks
        .where((b) => b.role == BlockRole.header || b.role == BlockRole.subheader)
        .toList();
    final bodyBlocks = slide.contentBlocks
        .where((b) => b.role != BlockRole.header && b.role != BlockRole.subheader)
        .toList();

    return Stack(
      children: [
        const BackgroundGradient(),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 80.0 * viewport.unifiedZoom,
              vertical: 60.0 * viewport.unifiedZoom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final block in headerBlocks)
                  StepAnimator(
                    isVisible: visibleStepCount >= block.revealStep,
                    child: BlockHeaderText(block: block),
                  ),
                if (headerBlocks.isNotEmpty) SizedBox(height: 28 * viewport.unifiedZoom),
                StandardBlocksBody(blocks: bodyBlocks, visibleStepCount: visibleStepCount),
              ],
            ),
          ),
        ),
      ],
    );
  }
}