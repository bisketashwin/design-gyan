import 'package:flutter/material.dart';

class PresentationFooter extends StatelessWidget {
  final int currentSlideIndex;
  final int totalSlides;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<int> onSelectSlide;

  const PresentationFooter({
    super.key,
    required this.currentSlideIndex,
    required this.totalSlides,
    required this.onNext,
    required this.onPrevious,
    required this.onSelectSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Slide Info & Navigation Buttons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white54),
              onPressed: currentSlideIndex > 0 ? onPrevious : null,
            ),
            Text(
              "SLIDE ${currentSlideIndex + 1} / $totalSlides",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white70,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onPressed: currentSlideIndex < totalSlides - 1 ? onNext : null,
            ),
          ],
        ),

        // Interactive Carousel Indicators
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
                  width: isSelected ? 46 : 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? const Color(0xFFFFB800)
                        : Colors.white24,
                  ),
                ),
              ),
            );
          }),
        ),

        const Text(
          "SPACE / ARROWS TO NAVIGATE",
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.white24,
          ),
        ),
      ],
    );
  }
}