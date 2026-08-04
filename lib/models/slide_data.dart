import 'package:design_gyan/commons/values.dart';

class MediaData {
  final String url;
  final String caption;
  final MediaType type;
  final CardAlignment alignment;
  final MediaFit fit;

  MediaData({
    required this.url,
    required this.caption,
    required this.type,
    this.alignment = CardAlignment.bottomRight,
    this.fit = MediaFit.cover,
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

    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

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
        }
        continue;
      }

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