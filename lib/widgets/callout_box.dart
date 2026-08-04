import 'package:flutter/material.dart';
import '../utils/markdown_formatter.dart';

class CalloutBox extends StatelessWidget {
  final String calloutText;

  const CalloutBox({
    super.key,
    required this.calloutText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFB800), width: 4),
        ),
      ),
      child: RichText(
        text: MarkdownFormatter.parseInline(
          calloutText,
          const TextStyle(
            fontSize: 19,
            height: 1.4,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}