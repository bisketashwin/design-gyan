import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'animators/step_animator.dart';
class SlideHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);

    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StepAnimator(
          isVisible: isTitleVisible,
          child: Padding(
            padding: EdgeInsets.only(bottom: (hasSubtitle ? 8 : 24) * viewport.unifiedZoom),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: baseUiSize * 2.85 * viewport.textScale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFB800),
                height: viewport.lineHeight,
                letterSpacing: 1.5 * viewport.unifiedZoom + viewport.letterSpacing,
              ),
            ),
          ),
        ),
        if (hasSubtitle)
          StepAnimator(
            isVisible: isSubtitleVisible,
            child: Padding(
              padding: EdgeInsets.only(bottom: 24 * viewport.unifiedZoom),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: baseUiSize * 2 * viewport.textScale,
                  color: const Color(0xFFE7E7E7),
                  height: viewport.lineHeight,
                  letterSpacing: viewport.letterSpacing,
                ),
              ),
            ),
          ),
      ],
    );
  }
}