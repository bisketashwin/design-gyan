import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
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

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
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
                      visibleStepCount: visibleStepCount,
                    ),
                    if (slide.callouts.isNotEmpty)
                      SizedBox(height: 28 * viewport.unifiedZoom),
                    ...slide.callouts.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final text = entry.value;
                      final isVisible =
                          visibleStepCount >= (calloutStartOffset + idx + 1);
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
      ],
    );
  }
}