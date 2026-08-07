import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleCardSlideView extends ConsumerWidget {
  final SlideData slide;
  final int visibleStepCount;

  const TitleCardSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);

    // Step sequence:
    // Step 1: Main Title
    // Step 2: Sub-header / Subtitle
    final isTitleVisible = visibleStepCount >= 1;
    final isSubHeaderVisible = visibleStepCount >= 2;

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 100.0 * viewport.unifiedZoom,
            vertical: 80.0 * viewport.unifiedZoom,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StepAnimator(
                  isVisible: isTitleVisible,
                  child: Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: baseUiSize * 4.5 * viewport.textScale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB800),
                      height: 1.15,
                      letterSpacing: (-0.5 * viewport.unifiedZoom) + viewport.letterSpacing,
                    ),
                  ),
                ),
                if (slide.subtitle != null && slide.subtitle!.isNotEmpty) ...[
                  SizedBox(height: 20 * viewport.unifiedZoom),
                  StepAnimator(
                    isVisible: isSubHeaderVisible,
                    child: Text(
                      slide.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: baseUiSize * 2.2 * viewport.textScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        height: viewport.lineHeight,
                        letterSpacing: (0.5 * viewport.unifiedZoom) + viewport.letterSpacing,
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