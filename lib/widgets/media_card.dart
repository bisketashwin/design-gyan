import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_data.dart';
import '../providers/viewport_setting_provider.dart';

class MediaCard extends ConsumerWidget {
  final MediaData media;
  const MediaCard({super.key, required this.media});

  BoxFit _getBoxFit() {
    switch (media.fit) {
      case MediaFit.contain:
        return BoxFit.contain;
      case MediaFit.cover:
      default:
        return BoxFit.cover;
    }
  }

  Widget _buildImage() {
    final fit = _getBoxFit();
    final isNetworkUrl = media.url.startsWith('http://') ||
        media.url.startsWith('https://');
    if (isNetworkUrl) {
      return Image.network(
        media.url,
        fit: fit,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
        ),
      );
    }
    return Image.asset(
      media.url,
      fit: fit,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final screenSize = MediaQuery.of(context).size;

    final double targetHeight = screenSize.height * ((media.heightFactor ?? 0.70) * viewport.mediaScale).clamp(0.20, 0.85);
    final double targetWidth = media.aspectRatio != null 
        ? targetHeight * media.aspectRatio!
        : screenSize.width * ((media.widthFactor ?? 0.30) * viewport.mediaScale).clamp(0.15, 0.80);

    return Container(
      width: targetWidth,
      height: targetHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(12 * viewport.unifiedZoom),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRect(
              child: _buildImage(),
            ),
          ),
          if (media.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12.0 * viewport.unifiedZoom),
              child: Text(
                media.caption,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: baseUiSize * 0.85 * viewport.textScale,
                  height: viewport.lineHeight,
                  letterSpacing: viewport.letterSpacing,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }
}