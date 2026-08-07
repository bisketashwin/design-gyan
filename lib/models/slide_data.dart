import 'package:design_gyan/commons/values.dart';

class GridItemData {
  final String label;
  final String imageUrl;

  GridItemData({required this.label, required this.imageUrl});
}

class MediaData {
  final String url;
  final String caption;
  final MediaType type;
  final CardAlignment alignment;
  final MediaFit fit;
  final double? widthFactor;
  final double? heightFactor;
  final double aspectRatio; // e.g., 3.0 for 3:1, 0.33 for 1:3
  final double heightPercent; // e.g., 0.15 for 15% of viewport height
  final MediaPlacement placement;

  MediaData({
    required this.url,
    required this.caption,
    required this.type,
    this.alignment = CardAlignment.bottomRight,
    this.fit = MediaFit.contain,
    this.widthFactor,
    this.heightFactor,
    this.aspectRatio = 1.0,
    this.heightPercent = 0.20, // Default 20% max height for inline
    this.placement = MediaPlacement.sideCard,
  });
}

/// Abstract representation of sequential content blocks for inline ordering
abstract class SlideBlockData {}

class TextBlockData extends SlideBlockData {
  final String text;
  final bool isHeader;
  final bool isSubheader;
  final bool isListItem;
  final bool isCallout;

  TextBlockData({
    required this.text,
    this.isHeader = false,
    this.isSubheader = false,
    this.isListItem = false,
    this.isCallout = false,
  });
}

class MediaBlockData extends SlideBlockData {
  final MediaData media;
  MediaBlockData({required this.media});
}

class SlideData {
  final String title;
  final String? subtitle;
  final List<String> callouts;
  final List<String> items;
  final List<GridItemData> gridItems;
  final MediaData? media; // Legacy side media support
  final List<SlideBlockData> blocks; // Ordered sequential content blocks
  final SlideType type;
  final GridDirection gridDirection;
  final int gridCount;

  SlideData({
    required this.title,
    this.subtitle,
    required this.callouts,
    required this.items,
    this.gridItems = const [],
    this.media,
    this.blocks = const [],
    this.type = SlideType.standard,
    this.gridDirection = GridDirection.column,
    this.gridCount = 3,
  });

  // -------------------------------------------------------------
  // HELPER PARSERS & UTILITIES
  // -------------------------------------------------------------
  static double parseAspectRatio(String val) {
    if (val.contains(':')) {
      final parts = val.split(':');
      final w = double.tryParse(parts[0]) ?? 1;
      final h = double.tryParse(parts[1]) ?? 1;
      return w / h;
    }
    return double.tryParse(val) ?? 1.0;
  }

  static double parseHeightPercent(String val) {
    final clean = val.replaceAll('%', '').trim();
    final parsed = double.tryParse(clean) ?? 20.0;
    return (parsed / 100.0).clamp(0.05, 0.80);
  }

  static CardAlignment _parseAlignment(String alignStr) {
    switch (alignStr) {
      case 'top-left': return CardAlignment.topLeft;
      case 'top-right': return CardAlignment.topRight;
      case 'middle-left': return CardAlignment.middleLeft;
      case 'middle-right': return CardAlignment.middleRight;
      case 'bottom-left': return CardAlignment.bottomLeft;
      case 'bottom-right': return CardAlignment.bottomRight;
      default: return CardAlignment.bottomRight;
    }
  }

  // -------------------------------------------------------------
  // FACTORY CONSTRUCTOR
  // -------------------------------------------------------------
  factory SlideData.fromMarkdown(String rawMarkdown) {
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

    // Active state tracker for inline comment directives
    double activeAspectRatio = 1.0;
    double activeHeightPercent = 0.20;
    MediaPlacement activePlacement = MediaPlacement.sideCard;

    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');
    bool isInsideCommentBlock = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 1. Handle Single-line Comments & Directives
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

      // 2. Handle Multi-line Comment Blocks
      if (line.startsWith('<!--')) {
        isInsideCommentBlock = true;
        continue;
      }
      if (line.endsWith('-->')) {
        isInsideCommentBlock = false;
        continue;
      }
      if (isInsideCommentBlock) continue;

      // 3. Handle Headers
      if (line.startsWith('# ')) {
        title = line.replaceFirst('# ', '');
        blocks.add(TextBlockData(text: title, isHeader: true));
      } else if (line.startsWith('## ')) {
        subtitle = line.replaceFirst('## ', '');
        blocks.add(TextBlockData(text: subtitle, isSubheader: true));
      } 
      // 4. Handle Callouts
      else if (line.startsWith('> ')) {
        final cleanText = line.replaceFirst('> ', '');
        callouts.add(cleanText);
        blocks.add(TextBlockData(text: cleanText, isCallout: true));
      }
      // 5. Handle Images & Media
      else if (line.startsWith('![')) {
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
      } 
      // 6. Handle List Items & Grid Items
      else if (line.startsWith('* ') ||
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

  // -------------------------------------------------------------
  // DECOUPLED PARSING SUITES
  // -------------------------------------------------------------
  static _DirectiveResult _parseCommentDirective({
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

    if (content.contains('ratio:') || content.contains('height:') || content.contains('mode:')) {
      final normalized = content.replaceAll(RegExp(r':\s+'), ':'); // "mode: inline" -> "mode:inline"
      final parts = normalized.split(RegExp(r'\s+'));
      for (var part in parts) {
        if (part.startsWith('ratio:')) {
          aspectRatio = parseAspectRatio(part.replaceFirst('ratio:', ''));
        } else if (part.startsWith('height:')) {
          heightPercent = parseHeightPercent(part.replaceFirst('height:', ''));
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

  static MediaData? _parseImageLine({
    required String line,
    required CardAlignment defaultAlignment,
    required MediaFit defaultFit,
    required double defaultAspectRatio,
    required double defaultHeightPercent,
    required MediaPlacement defaultPlacement,
  }) {
    final imageMatch = RegExp(r'^!\[(.*?)\]\((.*?)\)(?:\{(.*?)\})?$').firstMatch(line);
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
          finalRatio = parseAspectRatio(attr.replaceFirst('ratio=', ''));
        } else if (attr.startsWith('height=')) {
          finalHeightPercent = parseHeightPercent(attr.replaceFirst('height=', ''));
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

  static void _parseListLine({
    required String line,
    required SlideType slideType,
    required List<String> items,
    required List<GridItemData> gridItems,
    required List<SlideBlockData> blocks,
  }) {
    final cleanLine = line.replaceFirst(
      RegExp(r'^([\*\-]|(\d+\.))\s+'),
      '',
    );
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
}

/// Private DTO to convey parsed state out of comment parser
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