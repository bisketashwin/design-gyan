import 'package:design_gyan/commons/values.dart';

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
  final MediaData? media;
  final SlideType type;

  SlideData({
    required this.title,
    this.subtitle,
    required this.callouts,
    required this.items,
    this.media,
    this.type = SlideType.standard,
  });

  factory SlideData.fromMarkdown(String rawMarkdown) {
    String title = 'UNTITLED SLIDE';
    String? subtitle;
    List<String> callouts = [];
    List<String> items = [];
    MediaData? media;
    SlideType slideType = SlideType.standard;
    CardAlignment alignment = CardAlignment.bottomRight;
    MediaFit fit = MediaFit.cover;

    double? widthFactor;
    double? heightFactor;

    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');

    bool isInsideCommentBlock = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 1. Single-line comment check
      if (line.startsWith('<!--') && line.endsWith('-->')) {
        final content = line.replaceAll(RegExp(r'<!--|-->'), '').trim();

        if (content.startsWith('type:')) {
          if (content.replaceFirst('type:', '').trim() == 'full-media') {
            slideType = SlideType.fullMedia;
          }
        } else if (content.startsWith('align:')) {
          alignment = _parseAlignment(content.replaceFirst('align:', '').trim());
        } else if (content.startsWith('fit:')) {
          final fitStr = content.replaceFirst('fit:', '').trim();
          fit = fitStr == 'contain' ? MediaFit.contain : MediaFit.cover;
        } else if (content.startsWith('size:')) {
          final rawSize = content.replaceFirst('size:', '').trim();
          
          // Matches explicit labels e.g., width 40% height 50%
          final wMatch = RegExp(r'width\s+(\d+)%?').firstMatch(rawSize);
          final hMatch = RegExp(r'height\s+(\d+)%?').firstMatch(rawSize);

          if (wMatch != null) {
            final val = double.tryParse(wMatch.group(1)!);
            if (val != null) widthFactor = (val / 100.0).clamp(0.0, 1.0);
          }

          if (hMatch != null) {
            final val = double.tryParse(hMatch.group(1)!);
            if (val != null) heightFactor = (val / 100.0).clamp(0.0, 1.0);
          }

          // Fallback if no labels are present (e.g., size: 40% 50%)
          if (wMatch == null && hMatch == null) {
            final parts = rawSize.split(RegExp(r'\s+'));
            if (parts.isNotEmpty) {
              final wVal = double.tryParse(parts[0].replaceAll('%', ''));
              if (wVal != null) widthFactor = (wVal / 100.0).clamp(0.0, 1.0);
            }
            if (parts.length > 1) {
              final hVal = double.tryParse(parts[1].replaceAll('%', ''));
              if (hVal != null) heightFactor = (hVal / 100.0).clamp(0.0, 1.0);
            }
          }
        }
        continue;
      }

      // 2. Multi-line comment block start check
      if (line.startsWith('<!--')) {
        isInsideCommentBlock = true;
        continue;
      }

      // 3. Multi-line comment block end check
      if (line.endsWith('-->')) {
        isInsideCommentBlock = false;
        continue;
      }

      // 4. Ignore everything inside a comment block
      if (isInsideCommentBlock) {
        continue;
      }

      // 5. Standard Markdown parsing logic
      if (line.startsWith('# ')) {
        title = line.replaceFirst('# ', '');
      } else if (line.startsWith('## ')) {
        subtitle = line.replaceFirst('## ', '');
      } else if (line.startsWith('> ')) {
        callouts.add(line.replaceFirst('> ', ''));
      } else if (line.startsWith('![') || line.startsWith('[')) {
        final match = RegExp(r'^!?\[(.*?)\]\((.*?)\)$').firstMatch(line);
        if (match != null) {
          final caption = match.group(1) ?? '';
          final url = match.group(2) ?? '';
          final isVideo = url.contains('youtube.com') ||
              url.contains('youtu.be') ||
              url.endsWith('.mp4');
          media = MediaData(
            url: url,
            caption: caption,
            type: isVideo ? MediaType.video : MediaType.image,
            alignment: alignment,
            fit: fit,
            widthFactor: widthFactor,
            heightFactor: heightFactor,
          );
        }
      } else if (line.startsWith('* ') ||
          line.startsWith('- ') ||
          RegExp(r'^\d+\.\s+').hasMatch(line)) {
        items.add(line.replaceFirst(RegExp(r'^([\*\-]|(\d+\.))\s+'), ''));
      }
    }

    return SlideData(
      title: title,
      subtitle: subtitle,
      callouts: callouts,
      items: items,
      media: media,
      type: slideType,
    );
  }

  static CardAlignment _parseAlignment(String alignStr) {
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