// lib/widgets/slide_end_indicator.dart
import 'package:flutter/material.dart';

class SlideEndIndicator extends StatelessWidget {
  final bool isAtEnd;

  const SlideEndIndicator({super.key, required this.isAtEnd});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: isAtEnd ? 0 : -6,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAtEnd ? 1.0 : 0.0,
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB800),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withOpacity(0.8),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}