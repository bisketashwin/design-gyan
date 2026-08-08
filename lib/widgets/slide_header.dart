import 'package:flutter/material.dart';
import 'animators/step_animator.dart';

class SlideHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isTitleVisible;
  final bool isSubtitleVisible;
  final double baseUi;

  const SlideHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isTitleVisible = true,
    this.isSubtitleVisible = true,
    this.baseUi = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StepAnimator(
          isVisible: isTitleVisible,
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: baseUi * 2.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          StepAnimator(
            isVisible: isSubtitleVisible,
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: baseUi * 1.2,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ],
    );
  }
}