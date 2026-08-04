// lib/widgets/standard_slide.dart

import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import '../models/slide_data.dart';
import 'animators/step_animator.dart';
import 'callout_box.dart';
import 'media_card.dart';
import 'slide_content_list.dart';
import 'slide_header.dart';

class StandardSlideView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final media = slide.media;
    final headerSteps = 1 + (slide.subtitle != null ? 1 : 0);
    final calloutStartOffset = headerSteps;

    // Determine media width factor (defaults to 30% if not specified in MD)
    final mediaWidthFactor = media != null ? (media.widthFactor ?? 0.30) : 0.0;
    
    // Check if media is aligned on the left or right side
    final isMediaLeft = media != null &&
        (media.alignment == CardAlignment.topLeft ||
            media.alignment == CardAlignment.middleLeft ||
            media.alignment == CardAlignment.bottomLeft);

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 60.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. If media is configured to sit on the LEFT
              if (media != null && isMediaLeft) ...[
                Align(
                  alignment: getAlignment(media.alignment),
                  child: MediaCard(media: media),
                ),
                const SizedBox(width: 48),
              ],

              // 2. Text Content Area (Takes up all remaining space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideHeader(
                      title: slide.title,
                      subtitle: slide.subtitle,
                      visibleStepCount: visibleStepCount,
                    ),
                    if (slide.callouts.isNotEmpty) const SizedBox(height: 28),
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
                    const SizedBox(height: 120),
                  ],
                ),
              ),

              // 3. If media is configured to sit on the RIGHT (Default)
              if (media != null && !isMediaLeft) ...[
                const SizedBox(width: 48),
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