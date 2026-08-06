import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:flutter/material.dart';

class TitleCardSlideView extends StatelessWidget {
  final SlideData slide;
  final int visibleStepCount;

  const TitleCardSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context) {
    // Reveal main title on step 1, subtitle/callout on step 2 if present
    final isTitleVisible = visibleStepCount >= 1;
    final isSubtitleVisible = visibleStepCount >= 2;

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 80.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Centered Large Title
                StepAnimator(
                  isVisible: isTitleVisible,
                  child: Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB800), // Primary highlight / accent color
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // 2. Optional Centered Subtitle or Callout
                if (slide.subtitle != null) ...[
                  const SizedBox(height: 28),
                  StepAnimator(
                    isVisible: isSubtitleVisible,
                    child: Text(
                      slide.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
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