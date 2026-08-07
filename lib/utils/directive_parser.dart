import 'package:design_gyan/utils/progressive_grid_directives.dart';

class DirectiveParser {
  const DirectiveParser();

  ProgressiveGridDirectives parse(String markdown) {
    int columns = 3;
    double aspectRatio = 16 / 9;
    double? cardWidthPercent;

    // Matches <!-- type: progressive-grid ... --> across multiple lines
    final directiveMatch = RegExp(
      r'<!--\s*type:\s*progressive-grid(?::(\d+))?([\s\S]*?)-->',
      caseSensitive: false,
    ).firstMatch(markdown);

    if (directiveMatch != null) {
      if (directiveMatch.group(1) != null) {
        columns = int.tryParse(directiveMatch.group(1)!) ?? 3;
      }

      final rawAttributes = directiveMatch.group(2) ?? '';
      
      // Match key: value or key:value
      final attrMatches = RegExp(r'([\w-]+)\s*:\s*([^\s-->]+)').allMatches(rawAttributes);

      for (final match in attrMatches) {
        final key = match.group(1)?.toLowerCase();
        final value = match.group(2)?.trim();

        if (value == null) continue;

        if (key == 'aspect-ratio' || key == 'ratio') {
          aspectRatio = _parseAspectRatio(value);
        } else if (key == 'card-width' || key == 'width') {
          final cleanVal = value.replaceAll('%', '').trim();
          final parsedNum = double.tryParse(cleanVal);
          if (parsedNum != null && parsedNum > 0) {
            cardWidthPercent = parsedNum / 100.0;
          }
        }
      }
    }

    return ProgressiveGridDirectives(
      columns: columns,
      aspectRatio: aspectRatio,
      cardWidthPercent: cardWidthPercent,
    );
  }

  double _parseAspectRatio(String raw) {
    final clean = raw.trim();
    if (clean.contains(':')) {
      final parts = clean.split(':');
      final w = double.tryParse(parts[0]);
      final h = double.tryParse(parts[1]);
      if (w != null && h != null && h > 0) {
        return w / h; // 1:1 returns 1.0
      }
    }
    return double.tryParse(clean) ?? (16 / 9);
  }
}