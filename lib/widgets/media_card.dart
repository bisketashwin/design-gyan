import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import '../models/slide_data.dart';

class MediaCard extends StatelessWidget {
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
        alignment: Alignment.center, // Center-crop by default
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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final cardWidth = screenSize.width * (media.widthFactor ?? 0.30);
    final cardHeight = screenSize.height * (media.heightFactor ?? 0.45);

    return Container(
      width: cardWidth,
      height: cardHeight, // Lock exact height so cover mode crops properly
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(12.0),
              child: Text(
                media.caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}