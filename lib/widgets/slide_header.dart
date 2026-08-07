import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewport_setting_provider.dart';
import 'animators/step_animator.dart';

class SlideHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final bool isTitleVisible = visibleStepCount >= 1;
    final bool isSubtitleVisible = subtitle != null && visibleStepCount >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepAnimator(
          isVisible: isTitleVisible,
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: baseUiSize * 2.85 * viewport.textScale,
              fontWeight: FontWeight.w900,
              letterSpacing: (1.5 * viewport.unifiedZoom) + viewport.letterSpacing,
              color: const Color(0xFFFFB800),
            ),
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8 * viewport.unifiedZoom),
          StepAnimator(
            isVisible: isSubtitleVisible,
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: baseUiSize * 1.55 * viewport.textScale,
                fontStyle: FontStyle.italic,
                letterSpacing: viewport.letterSpacing,
                color: const Color(0xFF00F0FF),
              ),
            ),
          ),
        ],
      ],
    );
  }
}



class SlideHeader2 extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final int visibleStepCount;

  const SlideHeader2({
    super.key,
    required this.title,
    this.subtitle,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final bool isTitleVisible = visibleStepCount >= 1;
    final bool isSubtitleVisible = subtitle != null && visibleStepCount >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: baseUiSize * 2.85 * viewport.textScale,
            fontWeight: FontWeight.w900,
            letterSpacing: (1.5 * viewport.unifiedZoom) + viewport.letterSpacing,
            color: const Color(0xFFFFB800),
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8 * viewport.unifiedZoom),
          StepAnimator(
            isVisible: isSubtitleVisible,
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: baseUiSize * 1.55 * viewport.textScale,
                fontStyle: FontStyle.italic,
                letterSpacing: viewport.letterSpacing,
                color: const Color(0xFF00F0FF),
              ),
            ),
          ),
        ],
      ],
    );
  }
}