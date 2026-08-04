import 'dart:async';
import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/slide_data.dart';
import '../providers/presentation_provider.dart';
import '../utils/markdown_formatter.dart';

class FullMediaSlideView extends ConsumerStatefulWidget {
  final SlideData slide;
  final int visibleStepCount;

  const FullMediaSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  ConsumerState<FullMediaSlideView> createState() => _FullMediaSlideViewState();
}

class _FullMediaSlideViewState extends ConsumerState<FullMediaSlideView> {
  YoutubePlayerController? _youtubeController;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant FullMediaSlideView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slide.media?.url != widget.slide.media?.url) {
      _cleanupVideo();
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

        _playerStateSubscription =
            _youtubeController!.stream.listen((event) {
          if (event.playerState == PlayerState.ended) {
            ref.read(presentationProvider.notifier).nextSlideDirect();
          }
        });
      }
    }
  }

  void _cleanupVideo() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _youtubeController?.close();
    _youtubeController = null;
  }

  @override
  void dispose() {
    _cleanupVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.slide.media;

    return Stack(
      children: [
        const BackgroundGradient(),
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
                if (media != null)
                  Positioned.fill(child: _buildMediaView(media)),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.25)),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 80.0, vertical: 60.0),
            child: Align(
              alignment:
                  getAlignment(media?.alignment ?? CardAlignment.bottomRight),
              child: PointerInterceptor(
                child: _FloatingCard(slide: widget.slide),
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

  const _FloatingCard({required this.slide});

  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;

    return GestureDetector(
      onTap: () {}, // Blocks tap bubbling to presentation tap-handler
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isMinimized ? 320 : 520,
        constraints: BoxConstraints(maxHeight: _isMinimized ? 64 : 580),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF090A0F).withOpacity(0.92),
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
              children: [
                if (_isMinimized) ...[
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFFB800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    slide.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
              if (slide.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  slide.subtitle!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF00F0FF),
                  ),
                ),
              ],
              if (slide.callouts.isNotEmpty) const SizedBox(height: 12),
              ...slide.callouts.map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFFB800),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              if (slide.items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: slide.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚡ ", style: TextStyle(color: Color(0xFFFFB800))),
                            Expanded(
                              child: RichText(
                                text: MarkdownFormatter.parseInline(
                                  slide.items[index],
                                  const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}