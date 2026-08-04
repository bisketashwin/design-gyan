import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/slide_data.dart';
import '../utils/markdown_formatter.dart';
import 'animators/step_animator.dart';
import 'slide_header.dart';

class FullMediaSlideView extends StatefulWidget {
  final SlideData slide;
  final int visibleStepCount;

  const FullMediaSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  State<FullMediaSlideView> createState() => _FullMediaSlideViewState();
}

class _FullMediaSlideViewState extends State<FullMediaSlideView> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant FullMediaSlideView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slide.media?.url != widget.slide.media?.url) {
      _youtubeController?.close();
      _initVideo();
    }
  }

  void _initVideo() {
    final media = widget.slide.media;
    if (media != null && media.type == MediaType.video) {
      final videoId = YoutubePlayerController.convertUrlToId(media.url);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.slide.media;

    return Stack(
      children: [
        // Background canvas behind video frame
        const BackgroundGradient(),

        // Contained Frame (88% bounded viewport)
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 32,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (media != null) Positioned.fill(child: _buildMediaView(media)),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.25)),
                ),
              ],
            ),
          ),
        ),

        // Floating minimizable card sitting on top
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 60.0),
            child: Align(
              alignment: getAlignment(media?.alignment ?? CardAlignment.bottomRight),
              child: _FloatingCard(
                slide: widget.slide,
                visibleStepCount: widget.visibleStepCount,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaView(MediaData media) {
    if (media.type == MediaType.video && _youtubeController != null) {
      return YoutubePlayer(controller: _youtubeController!);
    }
    return Image.asset(
      media.url,
      fit: media.fit == MediaFit.contain ? BoxFit.contain : BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.white24),
      ),
    );
  }
}

class _FloatingCard extends StatefulWidget {
  final SlideData slide;
  final int visibleStepCount;

  const _FloatingCard({
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    final visibleStepCount = widget.visibleStepCount;
    final headerSteps = 1 + (slide.subtitle != null ? 1 : 0);
    final calloutStartOffset = headerSteps;
    final itemStartOffset = headerSteps + slide.callouts.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isMinimized ? 280 : 520,
      constraints: BoxConstraints(maxHeight: _isMinimized ? 72 : 580),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF090A0F).withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  slide.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFB800),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isMinimized ? Icons.open_in_full : Icons.close_fullscreen,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isMinimized = !_isMinimized;
                  });
                },
              ),
            ],
          ),
          if (!_isMinimized) ...[
            const SizedBox(height: 12),
            SlideHeader(
              title: "",
              subtitle: slide.subtitle,
              visibleStepCount: visibleStepCount,
            ),
            if (slide.callouts.isNotEmpty) const SizedBox(height: 16),
            ...slide.callouts.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final isVisible = visibleStepCount >= (calloutStartOffset + idx + 1);
              return StepAnimator(
                isVisible: isVisible,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFFB800),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }),
            if (slide.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: slide.items.length,
                  itemBuilder: (context, index) {
                    final isVisible = visibleStepCount >= (itemStartOffset + index + 1);
                    return StepAnimator(
                      isVisible: isVisible,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚡ ", style: TextStyle(color: Color(0xFFFFB800))),
                            Expanded(
                              child: RichText(
                                text: MarkdownFormatter.parseInline(
                                  slide.items[index],
                                  TextStyle(
                                    fontSize: 16,
                                    color: isVisible ? Colors.white70 : Colors.white24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}