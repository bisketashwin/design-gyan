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
    
    // Single entry point for UI Chrome typography baseline
    final baseUiSize = viewportSettings.getBaseUiSize(context);

    final isCustomScaled = viewportSettings.unifiedZoom != 1.0 ||
        viewportSettings.textScale != 1.0 ||
        viewportSettings.mediaScale != 1.0 ||
        viewportSettings.lineHeight != 1.4 ||
        viewportSettings.letterSpacing != 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Navigation Controls
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios, 
                size: baseUiSize * 1.2, // Proportional icon scale
                color: Colors.white54,
              ),
              onPressed: currentSlideIndex > 0 ? onPrevious : null,
            ),
            Text(
              "SLIDE ${currentSlideIndex + 1} / $totalSlides",
              style: TextStyle(
                fontSize: baseUiSize, // 1.0x Base
                fontWeight: FontWeight.bold,
                letterSpacing: 2 + viewportSettings.letterSpacing,
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
        ),

        // Slide Indicators
        Row(
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
                    color: isSelected
                        ? const Color(0xFFFFB800)
                        : Colors.white24,
                  ),
                ),
              ),
            );
          }),
        ),

        // Settings Button, Fullscreen Toggle & Shortcut Helper
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fullscreen Toggle Button
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

            // Viewport Settings Dialog Trigger
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: "Viewport & Readability Settings",
                  icon: Icon(
                    Icons.tune,
                    size: baseUiSize * 1.35, // Proportional settings icon
                    color: isCustomScaled
                        ? const Color(0xFF00F0FF)
                        : Colors.white54,
                  ),
                  onPressed: () => ViewportSettingsDialog.show(context),
                ),
                if (isCustomScaled)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: baseUiSize * 0.45,
                      height: baseUiSize * 0.45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00F0FF),
                        shape: BoxShape.circle,
                      ),
                    ),
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
                  fontSize: baseUiSize * 0.85, // 0.85x Small helper label
                  letterSpacing: 1.5 + viewportSettings.letterSpacing,
                  color: isAtSlideEnd ? Colors.black : Colors.white24,
                ),
              ),
            ),
          ],
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