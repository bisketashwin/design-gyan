import 'package:flutter/material.dart';
import 'animators/step_animator.dart';

class SlideHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int visibleStepCount;

  const SlideHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context) {
    // Step 0: Blank
    // Step 1: Title becomes visible
    final bool isTitleVisible = visibleStepCount >= 1;

    // Step 2: Subtitle becomes visible (if subtitle exists)
    final bool isSubtitleVisible = subtitle != null && visibleStepCount >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepAnimator(
          isVisible: isTitleVisible,
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Color(0xFFFFB800),
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          StepAnimator(
            isVisible: isSubtitleVisible,
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Color(0xFF00F0FF),
              ),
            ),
          ),
        ],
      ],
    );
  }
}