// lib/utils/progressive_grid_parser.dart
import 'package:design_gyan/models/progressive_grid_models.dart';
import 'package:design_gyan/utils/card_node_parser.dart';
import 'package:design_gyan/utils/directive_parser.dart';

class ProgressiveGridParser {
  final DirectiveParser _directiveParser;
  final CardNodeParser _cardNodeParser;

  const ProgressiveGridParser({
    DirectiveParser directiveParser = const DirectiveParser(),
    CardNodeParser cardNodeParser = const CardNodeParser(),
  })  : _directiveParser = directiveParser,
        _cardNodeParser = cardNodeParser;

  ProgressiveGridData parse(String markdown) {
    final directives = _directiveParser.parse(markdown);
    final lines = markdown.split('\n');
    final cardResult = _cardNodeParser.parseLines(lines, directives.aspectRatio);

    return ProgressiveGridData(
      title: cardResult.title,
      subheader: cardResult.subheader,
      signOff: cardResult.signOff, 
      footer: cardResult.footer,
      columns: directives.columns,
      cardWidthPercent: directives.cardWidthPercent,
      cards: cardResult.cards,
      maxSteps: cardResult.maxSteps,
    );
  }
}