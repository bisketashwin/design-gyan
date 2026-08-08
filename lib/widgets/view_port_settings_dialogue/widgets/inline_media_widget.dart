import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class InlineMediaWidget extends ConsumerWidget {
  final MediaData media;
  final bool showCaption;

  const InlineMediaWidget({super.key, required this.media, this.showCaption = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final screenSize = MediaQuery.of(context).size;

    // Calculate maximum allowable height based on screen height percentage & scale
    final double maxCalculatedHeight = 
        (screenSize.height * media.heightPercent) * viewport.mediaScale;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16.0 * viewport.unifiedZoom),
        constraints: BoxConstraints(
          maxHeight: maxCalculatedHeight +
              (media.caption.isNotEmpty ? 28.0 * viewport.unifiedZoom : 0),
          maxWidth: screenSize.width * 0.80, // Prevent exceeding slide boundaries
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // FIX: was CrossAxisAlignment.stretch, which forced this box to the
          // full available width (up to 80% of screen width) regardless of
          // the image's actual aspect ratio, squashing the AspectRatio child
          // and leaving a huge empty gap to the right of the image.
          // `start` lets the box size itself to the image's natural,
          // height-constrained dimensions and keeps it left-aligned.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxCalculatedHeight),
              child: AspectRatio(
                aspectRatio: media.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF121620),
                    borderRadius: BorderRadius.circular(8 * viewport.unifiedZoom),
                    border: Border.all(color: Colors.white12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    media.url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24, size: 32),
                    ),
                  ),
                ),
              ),
            ),
            if (media.caption.isNotEmpty && showCaption)
              Padding(
                padding: EdgeInsets.only(top: 6.0 * viewport.unifiedZoom),
                child: Text(
                  media.caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }
}