import 'package:design_gyan/commons/values.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/slide_data.dart';

class MediaCard extends StatefulWidget {
  final MediaData media;

  const MediaCard({super.key, required this.media});

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant MediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.url != widget.media.url) {
      _youtubeController?.close();
      _initVideo();
    }
  }

  void _initVideo() {
    if (widget.media.type == MediaType.video) {
      final videoId = YoutubePlayerController.convertUrlToId(widget.media.url);
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

  Widget _buildMediaView() {
    if (widget.media.type == MediaType.video && _youtubeController != null) {
      return YoutubePlayer(controller: _youtubeController!);
    }

    final isNetworkUrl = widget.media.url.startsWith('http://') || 
                         widget.media.url.startsWith('https://');

    if (isNetworkUrl) {
      return Image.network(
        widget.media.url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    }

    return Image.asset(
      widget.media.url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildMediaView(),
          ),
          if (widget.media.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.media.caption,
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