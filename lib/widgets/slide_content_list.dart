import 'package:flutter/material.dart';
import '../utils/markdown_formatter.dart';
import 'animators/step_animator.dart';

class SlideContentList extends StatelessWidget {
  final List<String> items;
  final int visibleItemCount;

  const SlideContentList({
    super.key,
    required this.items,
    required this.visibleItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isVisible = index < visibleItemCount;
          return StepAnimator(
            isVisible: isVisible,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⚡ ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: MarkdownFormatter.parseInline(
                        items[index],
                        TextStyle(
                          fontSize: 21,
                          height: 1.5,
                          color: isVisible ? Colors.white70 : Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}