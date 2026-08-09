import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/floating_media.dart';
import 'package:design_gyan/models/progressive_grid_models.dart';
import 'package:design_gyan/utils/markdown_slide_parser.dart';

class GridItemData {
  final String label;
  final String imageUrl;

  GridItemData({required this.label, required this.imageUrl});
}

class MediaData {
  final String rawUrl;
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
    required String url,
    required this.caption,
    required this.type,
    this.alignment = CardAlignment.bottomRight,
    this.fit = MediaFit.contain,
    this.widthFactor,
    this.heightFactor,
    this.aspectRatio = 1.0,
    this.heightPercent = 0.20, // Default 20% max height for inline
    this.placement = MediaPlacement.sideCard,
  }): rawUrl = url;

  bool get isNetwork => rawUrl.startsWith('http://') || rawUrl.startsWith('https://');

  String get url {
    if (isNetwork) return rawUrl;
    
    var path = rawUrl.trim();
    if (path.startsWith('assets/')) {
      return path.substring('assets/'.length);
    } else if (path.startsWith('/assets/')) {
      return path.substring('/assets/'.length);
    }
    return path;
  }

}

/// Abstract representation of sequential content blocks for inline ordering
abstract class SlideBlockData {
  final int revealStep;
  const SlideBlockData({this.revealStep = 0});
}

/// This would phase out other data types here

class Block {
  final BlockRole role;
  final String? text;
  final String? imageUrl;
  final String? imageCaption;
  final int revealStep;
  final double aspectRatio;
  final double heightPercent;

  const Block({
    required this.role,
    this.text,
    this.imageUrl,
    this.imageCaption,
    required this.revealStep,
    this.aspectRatio = 1.0,
    this.heightPercent = 0.20,
  }) : assert(text != null || imageUrl != null, 'Block needs text, image, or both');

  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isCompound => hasText && hasImage;
}

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
    super.revealStep,
  });
}

class MediaBlockData extends SlideBlockData {
  final MediaData media;
  MediaBlockData({required this.media, super.revealStep});
}

class SlideData {
  final String title;
  final String? subtitle;
  final List<String> callouts;
  final List<String> items;
  final List<GridItemData> gridItems;
  final ProgressiveGridData? progressiveGridData;
  final MediaData? media; // Legacy side media support
  final List<SlideBlockData> blocks; // legacy — untouched, still used by `standard`
  final List<Block> contentBlocks;     // new — used only by `standardBlocks`
  final SlideType type;
  final GridDirection gridDirection;
  final int gridCount;
  final FloatingMedia? floatingMedia;

  SlideData({
    required this.title,
    this.subtitle,
    required this.callouts,
    required this.items,
    this.gridItems = const [],
    this.progressiveGridData,
    this.media,
    this.blocks = const [],
    this.contentBlocks = const [],
    this.type = SlideType.standard,
    this.gridDirection = GridDirection.column,
    this.gridCount = 3,
    this.floatingMedia,
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
  
  int get _blockStepCount => contentBlocks.isEmpty ? 1 : contentBlocks.map((b) => b.revealStep).reduce((a, b) => a > b ? a : b);

  
  int get totalStepCount {
    switch (type) {
      case SlideType.standardBlocks:
        return _blockStepCount;

      case SlideType.progressiveGrid:
        return progressiveGridData?.maxSteps ?? 1;

      default:
        return 1 +
            (subtitle != null ? 1 : 0) +
            callouts.length +
            items.length +
            gridItems.length;
    }
  }
  // -------------------------------------------------------------
  // FACTORY CONSTRUCTOR
  // -------------------------------------------------------------
  factory SlideData.fromMarkdown(String rawMarkdown) {
    return const MarkdownSlideParser().parse(rawMarkdown);
  }

}