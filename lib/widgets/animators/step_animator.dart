import 'package:flutter/material.dart';

class StepAnimator extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const StepAnimator({
    super.key,
    required this.isVisible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0.03, 0),
        child: child,
      ),
    );
  }
}