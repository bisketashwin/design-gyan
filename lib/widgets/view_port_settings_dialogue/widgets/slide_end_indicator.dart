// lib/widgets/slide_end_indicator.dart
import 'package:flutter/material.dart';

class SlideEndIndicator extends StatelessWidget {
  final bool isAtEnd;

  const SlideEndIndicator({super.key, required this.isAtEnd});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      bottom: isAtEnd ? 0 : -10,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isAtEnd ? 1.0 : 0.0,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB800),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withOpacity(0.9),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}