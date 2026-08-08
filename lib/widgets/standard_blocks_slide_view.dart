import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/floating_media.dart';
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
    final floatingMedia = slide.floatingMedia;

    return Stack(
      children: [
        // RESTORED: Original background gradient
        const BackgroundGradient(),
        
        // RESTORED: Positioned fill with viewport-scaled padding
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 80.0 * viewport.unifiedZoom,
              vertical: 60.0 * viewport.unifiedZoom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RESTORED: Original animated header rendering
                for (final block in headerBlocks)
                  StepAnimator(
                    isVisible: visibleStepCount >= block.revealStep,
                    child: BlockHeaderText(block: block),
                  ),
                if (headerBlocks.isNotEmpty) 
                  SizedBox(height: 28 * viewport.unifiedZoom),
                
                // MERGED: Body wrapped in Expanded Row to reserve space for floating media
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: floatingMedia != null ? 7 : 10,
                        child: Padding(
                          // ADDED: Bottom padding here shrinks the render area vertically 
                          // ensuring the text list always ends clear of the footer controls.
                          padding: EdgeInsets.only(bottom: 80.0 * viewport.unifiedZoom),
                          child: Column(
                            children: [
                              Expanded(
                                child: StandardBlocksBody(
                                  blocks: bodyBlocks, 
                                  visibleStepCount: visibleStepCount
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (floatingMedia != null)
                        const Spacer(flex: 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // NEW: Floating Stacked Media Card Overlay
        if (floatingMedia != null)
          Align(
            alignment: floatingMedia.alignment,
            child: Padding(
              // Match viewport padding so the card aligns perfectly with text bounds
              padding: EdgeInsets.symmetric(
                horizontal: 80.0 * viewport.unifiedZoom,
                vertical: 60.0 * viewport.unifiedZoom,
              ),
              child: _buildStackedMediaCard(context, floatingMedia),
            ),
          ),
      ],
    );
  }
Widget _buildStackedMediaCard(BuildContext context, FloatingMedia media) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        double? cardWidth;
        double? cardHeight;

        final double maxH = constraints.maxHeight;
        final double maxW = constraints.maxWidth;

        if (media.widthPercent != null) {
          // 1. Explicit width specified in Markdown tag
          cardWidth = screenWidth * media.widthPercent!;
          if (media.aspectRatio != null) {
            cardHeight = cardWidth / media.aspectRatio!;
            // Clamp height if it exceeds available screen height
            if (cardHeight > maxH) {
              cardHeight = maxH;
              cardWidth = cardHeight * media.aspectRatio!;
            }
          }
        } else {
          // 2. No explicit width provided: Auto-fit based on Aspect Ratio
          if (media.aspectRatio != null) {
            if (media.aspectRatio! < 1.0) {
              // TALL IMAGE (e.g. 1:3) -> Fit Max Height first
              cardHeight = maxH;
              cardWidth = cardHeight * media.aspectRatio!;

              // Safety check: ensure width doesn't overflow right bounds
              if (cardWidth > maxW) {
                cardWidth = maxW;
                cardHeight = cardWidth / media.aspectRatio!;
              }
            } else {
              // WIDE IMAGE (e.g. 3:1) -> Fit Max Width first
              cardWidth = maxW;
              cardHeight = cardWidth / media.aspectRatio!;

              // Safety check: ensure height doesn't overflow vertical bounds
              if (cardHeight > maxH) {
                cardHeight = maxH;
                cardWidth = cardHeight * media.aspectRatio!;
              }
            }
          } else {
            // Fallback if neither ratio nor width is provided
            cardHeight = maxH;
          }
        }

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            // color: Theme.of(context).cardColor,
            // borderRadius: BorderRadius.circular(16),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Colors.black26,
            //     blurRadius: 20,
            //     offset: Offset(0, 8),
            //   ),
            // ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            media.imagePath,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
          ),
        );
      },
    );
  }
}