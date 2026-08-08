import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/models/floating_media.dart'; // <-- Add this import

class StandardBlocksParser {
  const StandardBlocksParser();

  SlideData parse(String rawMarkdown) {
    // 1. Extract and remove the floating media block first
    FloatingMedia? floatingMedia = parseFloatingMedia(rawMarkdown);
    if (floatingMedia != null) {
      // Remove the matched text from the raw markdown so it doesn't get parsed as a standard block
      // Note: Make sure the regex in floating_media.dart is accessible here
      final regex = RegExp(
        r'<!--\s*floating-media:\s*(.*?)\s*-->\s*\n\s*!\[(.*?)\]\((.*?)\)',
        multiLine: true,
      );
      rawMarkdown = rawMarkdown.replaceFirst(regex, '');
    }

    // 2. Proceed with standard line-by-line parsing
    final lines = rawMarkdown.replaceAll('\r\n', '\n').split('\n');
    String title = '';
    String? subtitle;
    final List<Block> blocks = [];
    int stepCursor = 0;
    bool isInsideCommentBlock = false;
    double defaultAspectRatio = 1.0;
    double defaultHeightPercent = 0.20;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Single-line comment: reset state and continue
      if (line.startsWith('<!--') && line.endsWith('-->')) {
        final content = line.replaceAll(RegExp(r'<!--|-->'), '').trim();
        if (content.contains('ratio:') || content.contains('height:')) {
          final normalized = content.replaceAll(RegExp(r':\s+'), ':');
          for (final part in normalized.split(RegExp(r'\s+'))) {
            if (part.startsWith('ratio:')) {
              defaultAspectRatio = SlideData.parseAspectRatio(part.replaceFirst('ratio:', ''));
            } else if (part.startsWith('height:')) {
              defaultHeightPercent = SlideData.parseHeightPercent(part.replaceFirst('height:', ''));
            }
          }
        }
        continue; 
      }

      // Multi-line comment boundary checks
      if (line.startsWith('<!--')) { 
        isInsideCommentBlock = true; 
        continue; 
      }
      if (line.endsWith('-->')) { 
        isInsideCommentBlock = false; 
        continue; 
      }
      if (isInsideCommentBlock) continue;

      final parsed = _parseLine(line, defaultAspectRatio, defaultHeightPercent);
      if (parsed == null) continue;

      stepCursor++;
      final block = Block(
        role: parsed.role,
        text: parsed.text,
        imageUrl: parsed.imageUrl,
        imageCaption: parsed.imageCaption,
        revealStep: stepCursor,
        aspectRatio: parsed.aspectRatio,
        heightPercent: parsed.heightPercent,
      );
      blocks.add(block);

      if (parsed.role == BlockRole.header) title = parsed.text ?? '';
      if (parsed.role == BlockRole.subheader) subtitle = parsed.text;
    }

    return SlideData(
      title: title,
      subtitle: subtitle,
      callouts: const [],
      items: const [],
      contentBlocks: blocks,
      type: SlideType.standardBlocks,
      floatingMedia: floatingMedia, // <-- Assign the extracted media here
    );
  }

  /// Parses one markdown line into its role + optional text + optional image.
  _ParsedLine? _parseLine(String trimmed, double defaultAspectRatio, double defaultHeightPercent) {
    String content = trimmed;
    BlockRole role;

    if (content.startsWith('# ')) {
      role = BlockRole.header;
      content = content.substring(2);
    } else if (content.startsWith('## ')) {
      role = BlockRole.subheader;
      content = content.substring(3);
    } else if (content.startsWith('### ')) {
      role = BlockRole.sectionHeader;
      content = content.substring(4);
    } else if (content.startsWith('> ')) {
      role = BlockRole.callout;
      content = content.substring(2);
    } else if (content.startsWith('* ') ||
        content.startsWith('- ') ||
        RegExp(r'^\d+\.\s+').hasMatch(content)) {
      role = BlockRole.bullet;
      content = content.replaceFirst(RegExp(r'^([\*\-]|(\d+\.))\s+'), '');
    } else if (content.startsWith('![')) {
      role = BlockRole.bullet;
    } else {
      return null;
    }

    final imgMatch = RegExp(r'!\[(.*?)\]\((.*?)\)(\{.*?\})?').firstMatch(content);
    String? imageUrl;
    String? imageCaption;
    String? text;
    double aspectRatio = defaultAspectRatio;
    double heightPercent = defaultHeightPercent;

    if (imgMatch != null) {
      imageCaption = imgMatch.group(1);
      imageUrl = imgMatch.group(2);
      final attrsRaw = imgMatch.group(3);
      if (attrsRaw != null) {
        final inner = attrsRaw.replaceAll(RegExp(r'[{}]'), '').trim();
        final normalized = inner.replaceAll(RegExp(r':\s+'), ':');
        for (final part in normalized.split(RegExp(r'\s+'))) {
          if (part.startsWith('ratio:')) {
            aspectRatio = SlideData.parseAspectRatio(part.replaceFirst('ratio:', ''));
          } else if (part.startsWith('height:')) {
            heightPercent = SlideData.parseHeightPercent(part.replaceFirst('height:', ''));
          }
        }
      }
      final leftover = content.replaceAll(imgMatch.group(0)!, '').trim();
      text = leftover.isEmpty ? null : leftover;
    } else {
      final leftover = content.trim();
      text = leftover.isEmpty ? null : leftover;
    }

    if (text == null && imageUrl == null) return null;

    return _ParsedLine(
      role: role,
      text: text,
      imageUrl: imageUrl,
      imageCaption: imageCaption,
      aspectRatio: aspectRatio,
      heightPercent: heightPercent,
    );
  }
}

class _ParsedLine {
  final BlockRole role;
  final String? text;
  final String? imageUrl;
  final String? imageCaption;
  final double aspectRatio;
  final double heightPercent;
  const _ParsedLine({
    required this.role,
    this.text,
    this.imageUrl,
    this.imageCaption,
    required this.aspectRatio,
    required this.heightPercent,
  });
}