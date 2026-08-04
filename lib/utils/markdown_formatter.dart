import 'package:flutter/material.dart';

class MarkdownFormatter {
  static TextSpan parseInline(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp mdRegex = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');

    int lastIndex = 0;
    for (final Match match in mdRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final String matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFB800),
          ),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: const Color(0xFF00F0FF),
          ),
        ));
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}