import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';

// Helper conversion in screen or widget
Alignment getAlignment(CardAlignment alignment) {
  switch (alignment) {
    case CardAlignment.topLeft: return Alignment.topLeft;
    case CardAlignment.topRight: return Alignment.topRight;
    case CardAlignment.middleLeft: return Alignment.centerLeft;
    case CardAlignment.middleRight: return Alignment.centerRight;
    case CardAlignment.bottomLeft: return Alignment.bottomLeft;
    case CardAlignment.bottomRight: return Alignment.bottomRight;
  }
}


class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.6),
            radius: 1.3,
            colors: [Color(0xFF141926), Color(0xFF090A0F)],
          ),
        ),
      ),
    );
  }
}