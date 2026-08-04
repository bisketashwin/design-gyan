import 'package:design_gyan/commons/helpers.dart';
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

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 60.0),
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
                final isVisible = visibleStepCount >= (calloutStartOffset + idx + 1);
                return StepAnimator(
                  isVisible: isVisible,
                  child: CalloutBox(calloutText: text),
                );
              }),
              SlideContentList(
                items: slide.items,
                visibleItemCount: visibleListItems,
              ),
            ],
          ),
        ),
        if (media != null)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 80.0,
                right: 80.0,
                top: 60.0,
                bottom: 80.0,
              ),
              child: Align(
                alignment: getAlignment(media.alignment),
                child: MediaCard(media: media),
              ),
            ),
          ),
      ],
    );
  }
}