import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/utils/progressive_grid_parser.dart';
import 'package:design_gyan/utils/standard_blocks_parser.dart';

/// Pure parser responsible for converting raw Markdown strings into structured [SlideData].
class MarkdownSlideParser {
  final ProgressiveGridParser progressiveGridParser;

  const MarkdownSlideParser({
    this.progressiveGridParser = const ProgressiveGridParser(),
  });

  SlideData parse(String rawMarkdown) {
    print('raw markdown parsing------------------');
    // ------------------------------------------------------------------------
    // INTERCEPT POINT: Check if rawMarkdown is a multi-line progressive grid.
    // ------------------------------------------------------------------------
    if (rawMarkdown.contains('type: standard-blocks')) {
      print('standard block parsing------------------');
      return const StandardBlocksParser().parse(rawMarkdown);
    }
    if (rawMarkdown.contains('progressive-grid') ||
        rawMarkdown.contains('<!-- card -->')) {
      final progressiveData = progressiveGridParser.parse(rawMarkdown);

      // Map ProgressiveGridData model to SlideData's gridItems list
      final List<GridItemData> gridItems = progressiveData.cards.map((card) {
        return GridItemData(label: card.title, imageUrl: card.imageUrl ?? '');
      }).toList();

      return SlideData(
        title: progressiveData.title,
        type: SlideType
            .progressiveGrid, // FIXED: Assigned progressiveGrid instead of grid
        gridCount: progressiveData.columns,
        progressiveGridData: progressiveData,
        gridItems: gridItems,
        items: const [],
        callouts: const [],
        blocks: const [],
      );
    }

    // ------------------------------------------------------------------------
    // STANDARD PARSER: Runs if the rawMarkdown is not a progressive grid block.
    // ------------------------------------------------------------------------
    String title = '';
    String? subtitle;
    List<String> callouts = [];
    List<String> items = [];
    List<GridItemData> gridItems = [];
    List<SlideBlockData> blocks = [];
    MediaData? sideMedia;
    SlideType slideType = SlideType.standard;
    GridDirection gridDirection = GridDirection.column;
    int gridCount = 3;
    CardAlignment alignment = CardAlignment.bottomRight;
    MediaFit fit = MediaFit.cover;
    double activeAspectRatio = 1.0;
    double activeHeightPercent = 0.20;
    MediaPlacement activePlacement = MediaPlacement.sideCard;

    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');
    bool isInsideCommentBlock = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('<!--') && line.endsWith('-->')) {
        final content = line.replaceAll(RegExp(r'<!--|-->'), '').trim();
        final directiveResult = _parseCommentDirective(
          content: content,
          currentSlideType: slideType,
          currentGridDirection: gridDirection,
          currentGridCount: gridCount,
          currentAlignment: alignment,
          currentFit: fit,
          activeAspectRatio: activeAspectRatio,
          activeHeightPercent: activeHeightPercent,
          activePlacement: activePlacement,
        );
        slideType = directiveResult.slideType;
        gridDirection = directiveResult.gridDirection;
        gridCount = directiveResult.gridCount;
        alignment = directiveResult.alignment;
        fit = directiveResult.fit;
        activeAspectRatio = directiveResult.aspectRatio;
        activeHeightPercent = directiveResult.heightPercent;
        activePlacement = directiveResult.placement;
        continue;
      }

      if (line.startsWith('<!--')) {
        isInsideCommentBlock = true;
        continue;
      }
      if (line.endsWith('-->')) {
        isInsideCommentBlock = false;
        continue;
      }
      if (isInsideCommentBlock) continue;

      if (line.startsWith('# ')) {
        title = line.replaceFirst('# ', '');
        blocks.add(TextBlockData(text: title, isHeader: true));
      } else if (line.startsWith('## ')) {
        subtitle = line.replaceFirst('## ', '');
        blocks.add(TextBlockData(text: subtitle, isSubheader: true));
      } else if (line.startsWith('> ')) {
        final cleanText = line.replaceFirst('> ', '');
        callouts.add(cleanText);
        blocks.add(TextBlockData(text: cleanText, isCallout: true));
      } else if (line.startsWith('![')) {
        final parsedMedia = _parseImageLine(
          line: line,
          defaultAlignment: alignment,
          defaultFit: fit,
          defaultAspectRatio: activeAspectRatio,
          defaultHeightPercent: activeHeightPercent,
          defaultPlacement: activePlacement,
        );
        if (parsedMedia != null) {
          if (parsedMedia.placement == MediaPlacement.inline) {
            blocks.add(MediaBlockData(media: parsedMedia));
          } else {
            sideMedia = parsedMedia;
          }
        }
      } else if (line.startsWith('* ') ||
          line.startsWith('- ') ||
          RegExp(r'^\d+\.\s+').hasMatch(line)) {
        _parseListLine(
          line: line,
          slideType: slideType,
          items: items,
          gridItems: gridItems,
          blocks: blocks,
        );
      }
    }

    return SlideData(
      title: title,
      subtitle: subtitle,
      callouts: callouts,
      items: items,
      gridItems: gridItems,
      media: sideMedia,
      blocks: blocks,
      type: slideType,
      gridDirection: gridDirection,
      gridCount: gridCount,
    );
  }

  _DirectiveResult _parseCommentDirective({
    required String content,
    required SlideType currentSlideType,
    required GridDirection currentGridDirection,
    required int currentGridCount,
    required CardAlignment currentAlignment,
    required MediaFit currentFit,
    required double activeAspectRatio,
    required double activeHeightPercent,
    required MediaPlacement activePlacement,
  }) {
    SlideType slideType = currentSlideType;
    GridDirection gridDirection = currentGridDirection;
    int gridCount = currentGridCount;
    CardAlignment alignment = currentAlignment;
    MediaFit fit = currentFit;
    double aspectRatio = activeAspectRatio;
    double heightPercent = activeHeightPercent;
    MediaPlacement placement = activePlacement;

    if (content.contains('ratio:') ||
        content.contains('height:') ||
        content.contains('mode:')) {
      final normalized = content.replaceAll(RegExp(r':\s+'), ':');
      final parts = normalized.split(RegExp(r'\s+'));
      for (var part in parts) {
        if (part.startsWith('ratio:')) {
          aspectRatio = SlideData.parseAspectRatio(
            part.replaceFirst('ratio:', ''),
          );
        } else if (part.startsWith('height:')) {
          heightPercent = SlideData.parseHeightPercent(
            part.replaceFirst('height:', ''),
          );
        } else if (part.startsWith('mode:')) {
          placement = part.replaceFirst('mode:', '') == 'inline'
              ? MediaPlacement.inline
              : MediaPlacement.sideCard;
        }
      }
    } else if (content.startsWith('type:')) {
      final typeValue = content.replaceFirst('type:', '').trim();
      if (typeValue == 'full-media') {
        slideType = SlideType.fullMedia;
      } else if (typeValue == 'title-card') {
        slideType = SlideType.titleCard;
      } else if (typeValue.startsWith('cards-grid:')) {
        slideType = SlideType.grid;
        final gridParts = typeValue
            .replaceFirst('cards-grid:', '')
            .trim()
            .split(RegExp(r'\s+'));
        if (gridParts.isNotEmpty) {
          gridDirection = gridParts[0] == 'row'
              ? GridDirection.row
              : GridDirection.column;
        }
        if (gridParts.length > 1) {
          gridCount = int.tryParse(gridParts[1]) ?? 3;
        }
      }
    } else if (content.startsWith('align:')) {
      alignment = _parseAlignment(content.replaceFirst('align:', '').trim());
    } else if (content.startsWith('fit:')) {
      final fitStr = content.replaceFirst('fit:', '').trim();
      fit = fitStr == 'contain' ? MediaFit.contain : MediaFit.cover;
    }

    return _DirectiveResult(
      slideType: slideType,
      gridDirection: gridDirection,
      gridCount: gridCount,
      alignment: alignment,
      fit: fit,
      aspectRatio: aspectRatio,
      heightPercent: heightPercent,
      placement: placement,
    );
  }

  MediaData? _parseImageLine({
    required String line,
    required CardAlignment defaultAlignment,
    required MediaFit defaultFit,
    required double defaultAspectRatio,
    required double defaultHeightPercent,
    required MediaPlacement defaultPlacement,
  }) {
    final imageMatch = RegExp(
      r'^!\[(.*?)\]\((.*?)\)(?:\{(.*?)\})?$',
    ).firstMatch(line);
    if (imageMatch == null) return null;

    final caption = imageMatch.group(1) ?? '';
    final url = imageMatch.group(2) ?? '';
    final attributes = imageMatch.group(3);

    double finalRatio = defaultAspectRatio;
    double finalHeightPercent = defaultHeightPercent;
    MediaPlacement finalPlacement = defaultPlacement;

    if (attributes != null && attributes.isNotEmpty) {
      final attrParts = attributes.split(' ');
      for (var attr in attrParts) {
        if (attr.startsWith('ratio=')) {
          finalRatio = SlideData.parseAspectRatio(
            attr.replaceFirst('ratio=', ''),
          );
        } else if (attr.startsWith('height=')) {
          finalHeightPercent = SlideData.parseHeightPercent(
            attr.replaceFirst('height=', ''),
          );
        } else if (attr.startsWith('mode=')) {
          finalPlacement = attr.replaceFirst('mode=', '') == 'inline'
              ? MediaPlacement.inline
              : MediaPlacement.sideCard;
        }
      }
    }

    final isVideo = url.contains('youtube.com') || url.contains('youtu.be');
    return MediaData(
      url: url,
      caption: caption,
      type: isVideo ? MediaType.video : MediaType.image,
      alignment: defaultAlignment,
      fit: defaultFit,
      aspectRatio: finalRatio,
      heightPercent: finalHeightPercent,
      placement: finalPlacement,
    );
  }

  void _parseListLine({
    required String line,
    required SlideType slideType,
    required List<String> items,
    required List<GridItemData> gridItems,
    required List<SlideBlockData> blocks,
  }) {
    final cleanLine = line.replaceFirst(RegExp(r'^([\*\-]|(\d+\.))\s+'), '');
    final gridItemMatch = RegExp(
      r'^(.*?)\s*,?\s*\((assets\/.*?|https?:\/\/.*?)\)$',
    ).firstMatch(cleanLine);

    if (gridItemMatch != null && slideType == SlideType.grid) {
      final label = gridItemMatch.group(1)?.trim() ?? '';
      final imageUrl = gridItemMatch.group(2)?.trim() ?? '';

      gridItems.add(GridItemData(label: label, imageUrl: imageUrl));
    } else {
      items.add(cleanLine);
      blocks.add(TextBlockData(text: cleanLine, isListItem: true));
    }
  }

  CardAlignment _parseAlignment(String alignStr) {
    switch (alignStr) {
      case 'top-left':
        return CardAlignment.topLeft;
      case 'top-right':
        return CardAlignment.topRight;
      case 'middle-left':
        return CardAlignment.middleLeft;
      case 'middle-right':
        return CardAlignment.middleRight;
      case 'bottom-left':
        return CardAlignment.bottomLeft;
      case 'bottom-right':
        return CardAlignment.bottomRight;
      default:
        return CardAlignment.bottomRight;
    }
  }
}

class _DirectiveResult {
  final SlideType slideType;
  final GridDirection gridDirection;
  final int gridCount;
  final CardAlignment alignment;
  final MediaFit fit;
  final double aspectRatio;
  final double heightPercent;
  final MediaPlacement placement;

  _DirectiveResult({
    required this.slideType,
    required this.gridDirection,
    required this.gridCount,
    required this.alignment,
    required this.fit,
    required this.aspectRatio,
    required this.heightPercent,
    required this.placement,
  });
}
