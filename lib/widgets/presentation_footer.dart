import 'package:design_gyan/providers/presentation_provider.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/viewport_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationFooter extends ConsumerWidget {
  final int currentSlideIndex;
  final int totalSlides;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<int> onSelectSlide;
  final bool isAtSlideEnd;

  const PresentationFooter({
    super.key,
    required this.currentSlideIndex,
    required this.totalSlides,
    required this.onNext,
    required this.onPrevious,
    required this.onSelectSlide,
    required this.isAtSlideEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewportSettings = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewportSettings.getBaseUiSize(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SlideNavigationControls(
          currentSlideIndex: currentSlideIndex,
          totalSlides: totalSlides,
          onPrevious: onPrevious,
          onNext: onNext,
          baseUiSize: baseUiSize,
          letterSpacing: viewportSettings.letterSpacing,
        ),
        _SlideIndicators(
          currentSlideIndex: currentSlideIndex,
          totalSlides: totalSlides,
          onSelectSlide: onSelectSlide,
          baseUiSize: baseUiSize,
        ),
        _ViewportActionGroup(
          isAtSlideEnd: isAtSlideEnd,
          baseUiSize: baseUiSize,
        ),
      ],
    );
  }
}

class _SlideNavigationControls extends StatelessWidget {
  final int currentSlideIndex;
  final int totalSlides;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double baseUiSize;
  final double letterSpacing;

  const _SlideNavigationControls({
    required this.currentSlideIndex,
    required this.totalSlides,
    required this.onPrevious,
    required this.onNext,
    required this.baseUiSize,
    required this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: baseUiSize * 1.2,
            color: Colors.white54,
          ),
          onPressed: currentSlideIndex > 0 ? onPrevious : null,
        ),
        Text(
          "SLIDE ${currentSlideIndex + 1} / $totalSlides",
          style: TextStyle(
            fontSize: baseUiSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2 + letterSpacing,
            color: Colors.white70,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: baseUiSize * 1.2,
            color: Colors.white54,
          ),
          onPressed: currentSlideIndex < totalSlides - 1 ? onNext : null,
        ),
      ],
    );
  }
}

class _SlideIndicators extends StatelessWidget {
  final int currentSlideIndex;
  final int totalSlides;
  final ValueChanged<int> onSelectSlide;
  final double baseUiSize;

  const _SlideIndicators({
    required this.currentSlideIndex,
    required this.totalSlides,
    required this.onSelectSlide,
    required this.baseUiSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSlides, (idx) {
        final isSelected = idx == currentSlideIndex;
        return GestureDetector(
          onTap: () => onSelectSlide(idx),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? baseUiSize * 3.5 : baseUiSize * 1.5,
              height: baseUiSize * 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(baseUiSize * 0.75),
                color: isSelected ? const Color(0xFFFFB800) : Colors.white24,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ViewportActionGroup extends ConsumerWidget {
  final bool isAtSlideEnd;
  final double baseUiSize;

  const _ViewportActionGroup({
    required this.isAtSlideEnd,
    required this.baseUiSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewportSettings = ref.watch(viewportSettingsProvider);
    final viewportNotifier = ref.read(viewportSettingsProvider.notifier);

    final isCustomScaled = viewportSettings.unifiedZoom != 1.0 ||
        viewportSettings.textScale != 1.0 ||
        viewportSettings.mediaScale != 1.0 ||
        viewportSettings.lineHeight != 1.4 ||
        viewportSettings.letterSpacing != 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: "Decrease Text Size",
          icon: Icon(
            Icons.text_decrease,
            size: baseUiSize * 1.35,
            color: Colors.white54,
          ),
          onPressed: viewportSettings.textScale > 0.5
              ? () => viewportNotifier.setTextScale(
                    (viewportSettings.textScale - 0.1).clamp(0.5, 2.0),
                  )
              : null,
        ),
        IconButton(
          tooltip: "Increase Text Size",
          icon: Icon(
            Icons.text_increase,
            size: baseUiSize * 1.35,
            color: Colors.white54,
          ),
          onPressed: viewportSettings.textScale < 2.0
              ? () => viewportNotifier.setTextScale(
                    (viewportSettings.textScale + 0.1).clamp(0.5, 2.0),
                  )
              : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: "Toggle Fullscreen",
          icon: Icon(
            Icons.fullscreen,
            size: baseUiSize * 1.35,
            color: Colors.white54,
          ),
          onPressed: () {
            ref.read(presentationProvider.notifier).toggleFullscreen();
          },
        ),
        const SizedBox(width: 4),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: "Viewport & Readability Settings",
              icon: Icon(
                Icons.tune,
                size: baseUiSize * 1.35,
                color: Colors.white54,
              ),
              onPressed: () => ViewportSettingsDialog.show(context),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          color: isAtSlideEnd ? const Color(0xFFFFB800) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            _keyboardInteractionMessage(viewportSettings.isFrictionEnabled),
            style: TextStyle(
              fontSize: baseUiSize * 0.85,
              letterSpacing: 1.5 + viewportSettings.letterSpacing,
              color: isAtSlideEnd ? Colors.black : Colors.white24,
            ),
          ),
        ),
      ],
    );
  }

  String _keyboardInteractionMessage(bool frictionOn) {
    if (frictionOn) {
      return "DOUBLE TAP SPACE/ARROWS TO NEXT SLIDE";
    }
    return "SPACE / ARROWS TO NAVIGATE";
  }
}