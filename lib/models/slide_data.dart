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

  MediaData({
    required this.url,
    required this.caption,
    required this.type,
    this.alignment = CardAlignment.bottomRight,
    this.fit = MediaFit.cover,
    this.widthFactor,
    this.heightFactor,
  });
}

class SlideData {
  final String title;
  final String? subtitle;
  final List<String> callouts;
  final List<String> items;
  final List<GridItemData> gridItems; // Item grid list
  final MediaData? media;
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
    this.type = SlideType.standard,
    this.gridDirection = GridDirection.column,
    this.gridCount = 3,
  });

  factory SlideData.fromMarkdown(String rawMarkdown) {
    String title = 'UNTITLED SLIDE';
    String? subtitle;
    List<String> callouts = [];
    List<String> items = [];
    List<GridItemData> gridItems = [];
    MediaData? media;
    SlideType slideType = SlideType.standard;
    GridDirection gridDirection = GridDirection.column;
    int gridCount = 3;
    CardAlignment alignment = CardAlignment.bottomRight;
    MediaFit fit = MediaFit.cover;
    double? widthFactor;
    double? heightFactor;

    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');
    bool isInsideCommentBlock = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('<!--') && line.endsWith('-->')) {
        final content = line.replaceAll(RegExp(r'<!--|-->'), '').trim();
        
        if (content.startsWith('type:')) {
          final typeValue = content.replaceFirst('type:', '').trim();
          if (typeValue == 'full-media') {
            slideType = SlideType.fullMedia;
          } else if (typeValue == 'title-card') {
            slideType = SlideType.titleCard; 
          } else if (typeValue.startsWith('cards-grid:')) {
            slideType = SlideType.grid;
            // Parse "cards-grid:column 3" or "cards-grid:row 2"
            final gridParts = typeValue.replaceFirst('cards-grid:', '').trim().split(RegExp(r'\s+'));
            if (gridParts.isNotEmpty) {
              gridDirection = gridParts[0] == 'row' ? GridDirection.row : GridDirection.column;
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
        continue;
      }

      if (line.startsWith('<!--')) { isInsideCommentBlock = true; continue; }
      if (line.endsWith('-->')) { isInsideCommentBlock = false; continue; }
      if (isInsideCommentBlock) continue;

      if (line.startsWith('# ')) {
        title = line.replaceFirst('# ', '');
      } else if (line.startsWith('## ')) {
        subtitle = line.replaceFirst('## ', '');
      } else if (line.startsWith('> ')) {
        callouts.add(line.replaceFirst('> ', ''));
      } else if (line.startsWith('* ') || line.startsWith('- ') || RegExp(r'^\d+\.\s+').hasMatch(line)) {
        // Match label and optional image URL: "Label (assets/image.jpg)"
        final cleanLine = line.replaceFirst(RegExp(r'^([\*\-]|(\d+\.))\s+'), '');
        // Updated regex: optional comma before image path
        final gridItemMatch = RegExp(r'^(.*?)\s*,?\s*\((assets\/.*?|https?:\/\/.*?)\)$').firstMatch(cleanLine);
        if (gridItemMatch != null) {
          final label = gridItemMatch.group(1)?.trim() ?? '';
          final imageUrl = gridItemMatch.group(2)?.trim() ?? '';
          gridItems.add(GridItemData(label: label, imageUrl: imageUrl));
        } else {
          items.add(cleanLine);
        }
      }
    }

    return SlideData(
      title: title,
      subtitle: subtitle,
      callouts: callouts,
      items: items,
      gridItems: gridItems,
      media: media,
      type: slideType,
      gridDirection: gridDirection,
      gridCount: gridCount,
    );
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
}