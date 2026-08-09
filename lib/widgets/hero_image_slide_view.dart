import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeroImageSlideView extends ConsumerWidget {
  final SlideData slide;
  final int visibleStepCount;

  const HeroImageSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final media = slide.media;
    final baseUiSize = viewport.getBaseUiSize(context);
        final isTitleVisible = visibleStepCount >= 1;
    final isSubHeaderVisible = visibleStepCount >= 2;
    debugPrint("Media Url: ${media?.url}");
    return Stack(
      children: [
        const BackgroundGradient(),
        // Hero Image Container
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.all(32.0 * viewport.unifiedZoom),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * viewport.unifiedZoom),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (media != null)
                  Image.asset(
                    media.url,
                    fit: media.fit == MediaFit.contain
                        ? BoxFit.contain
                        : BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 64, color: Colors.white24),
                    ),
                  ),
                // Gradient overlay to maintain text legibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(
              horizontal: viewport.getBaseUiSize(context) * 10),
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
                          fontSize: baseUiSize * 4.5 * viewport.textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
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