import 'package:flutter/widgets.dart';

class FloatingMedia {
  final String imagePath;
  final String altText;
  final Alignment alignment;
  final double? widthPercent;
  final double? heightPercent;
  final double? aspectRatio;

  FloatingMedia({
    required this.imagePath,
    required this.altText,
    this.alignment = Alignment.centerRight,
    this.widthPercent,
    this.heightPercent,
    this.aspectRatio,
  });
}

// Regex to capture: <!-- floating-media: align=middle-right width=25% ratio=1:3 -->
final _floatingMediaRegex = RegExp(
  r'<!--\s*floating-media:\s*(.*?)\s*-->\s*\n\s*!\[(.*?)\]\((.*?)\)',
  multiLine: true,
);

FloatingMedia? parseFloatingMedia(String markdownBlock) {
  final match = _floatingMediaRegex.firstMatch(markdownBlock);
  if (match == null) return null;

  final paramsString = match.group(1) ?? '';
  final altText = match.group(2) ?? '';
  final imagePath = match.group(3) ?? '';

  // Parse key-value params from "align=middle-right width=25% ratio=1:3"
  final params = <String, String>{};
  for (final pair in paramsString.split(RegExp(r'\s+'))) {
    final kv = pair.split('=');
    if (kv.length == 2) params[kv[0]] = kv[1];
  }

  return FloatingMedia(
    imagePath: imagePath,
    altText: altText,
    alignment: _parseAlignment(params['align']),
    widthPercent: _parsePercent(params['width']),
    heightPercent: _parsePercent(params['height']),
    aspectRatio: _parseAspectRatio(params['ratio']),
  );
}

Alignment _parseAlignment(String? align) {
  switch (align) {
    case 'top-right':
      return Alignment.topRight;
    case 'bottom-right':
      return Alignment.bottomRight;
    case 'middle-right':
    default:
      return Alignment.centerRight;
  }
}

double? _parsePercent(String? val) {
  if (val == null) return null;
  final clean = val.replaceAll('%', '').trim();
  final num = double.tryParse(clean);
  return num != null ? num / 100.0 : null;
}

double? _parseAspectRatio(String? val) {
  if (val == null) return null;
  final parts = val.split(':');
  if (parts.length == 2) {
    final w = double.tryParse(parts[0]);
    final h = double.tryParse(parts[1]);
    if (w != null && h != null && h != 0) return w / h;
  }
  return null;
}