import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/widgets/slide_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
import '../providers/viewport_setting_provider.dart';
import 'animators/step_animator.dart';
import 'callout_box.dart';
import 'media_card.dart';
import 'slide_content_list.dart';
import 'slide_header.dart';

class StandardSlideView extends ConsumerWidget {
  final SlideData slide;
  final int visibleStepCount;
  final int visibleListItems;
  const StandardSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
    required this.visibleListItems,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final media = slide.media;
    final headerSteps = 1 + (slide.subtitle != null ? 1 : 0);
    final calloutStartOffset = headerSteps;
    final isMediaLeft = media != null &&
        (media.alignment == CardAlignment.topLeft ||
            media.alignment == CardAlignment.middleLeft ||
            media.alignment == CardAlignment.bottomLeft);
    final horizontalPadding = 80.0 * viewport.unifiedZoom;
    final verticalPadding = 60.0 * viewport.unifiedZoom;
    final bool hasInlineBlocks = slide.blocks.any((b) => b is MediaBlockData);
    return Stack(
      children: [
        const BackgroundGradient(),
        // FIX: both branches below used to be plain (non-positioned) Stack
        // children. A Stack with non-positioned children sizes itself to
        // those children's natural content size instead of filling the
        // available space. For short-content slides (e.g. inline-media
        // slides with just a title + small image + a few bullets), that
        // left the Stack shorter than the viewport, which in turn pulled
        // the footer (Positioned(bottom: 30, ...) in the parent Stack)
        // up with it instead of staying pinned to the true screen bottom.
        // Wrapping in Positioned.fill forces the Stack to always expand
        // to fill its full available space regardless of content length.
        if (hasInlineBlocks)
          Positioned.fill(child: SlideRenderer(slide: slide))
        else
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media != null && isMediaLeft) ...[
                    Align(
                      alignment: getAlignment(media.alignment),
                      child: MediaCard(media: media),
                    ),
                    SizedBox(width: 48 * viewport.unifiedZoom),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideHeader(
                          title: slide.title,
                          subtitle: slide.subtitle,
                        ),
                        if (slide.callouts.isNotEmpty)
                          SizedBox(height: 28 * viewport.unifiedZoom),
                        ...slide.callouts.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final text = entry.value;
                          final isVisible = visibleStepCount >=
                              (calloutStartOffset + idx + 1);
                          return StepAnimator(
                            isVisible: isVisible,
                            child: CalloutBox(calloutText: text),
                          );
                        }),
                        SlideContentList(
                          items: slide.items,
                          visibleItemCount: visibleListItems,
                        ),
                        SizedBox(height: 120 * viewport.unifiedZoom),
                      ],
                    ),
                  ),
                  if (media != null && !isMediaLeft) ...[
                    SizedBox(width: 48 * viewport.unifiedZoom),
                    Align(
                      alignment: getAlignment(media.alignment),
                      child: MediaCard(media: media),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}