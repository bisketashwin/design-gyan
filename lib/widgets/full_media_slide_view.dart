import 'dart:async';
import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/widgets/floating_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/slide_data.dart';
import '../providers/presentation_provider.dart';

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
    final viewport = ref.watch(viewportSettingsProvider);
    final media = widget.slide.media;

    final baseWidth = MediaQuery.of(context).size.width * 0.88;
    final baseHeight = MediaQuery.of(context).size.height * 0.85;

    final scaledWidth = (baseWidth * viewport.mediaScale).clamp(
      300.0,
      MediaQuery.of(context).size.width,
    );
    final scaledHeight = (baseHeight * viewport.mediaScale).clamp(
      200.0,
      MediaQuery.of(context).size.height,
    );

    return Stack(
      children: [
        const BackgroundGradient(),
        Center(
          child: Container(
            width: scaledWidth,
            height: scaledHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16 * viewport.unifiedZoom),
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
            padding: EdgeInsets.symmetric(
              horizontal: 80.0 * viewport.unifiedZoom,
              vertical: 60.0 * viewport.unifiedZoom,
            ),
            child: Align(
              alignment:
                  getAlignment(media?.alignment ?? CardAlignment.bottomRight),
              child: PointerInterceptor(
                child: FloatingCard(slide: widget.slide),
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