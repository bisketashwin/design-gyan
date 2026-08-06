class YoutubeUrlParser {
  static YoutubeVideoData parse(String url) {
    // 1. Extract Video ID
    final idRegExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final idMatch = idRegExp.firstMatch(url);
    final videoId = idMatch?.group(1);

    // 2. Extract Start Time in Seconds
    int startSeconds = 0;
    final timeRegExp = RegExp(r'[?&]t=([0-9a-zA-Z]+)');
    final timeMatch = timeRegExp.firstMatch(url);

    if (timeMatch != null) {
      final timeStr = timeMatch.group(1)!;
      startSeconds = _parseSeconds(timeStr);
    }

    return YoutubeVideoData(videoId: videoId, startSeconds: startSeconds);
  }

  static int _parseSeconds(String timeStr) {
    // Handles raw seconds like "?t=94"
    if (RegExp(r'^\d+$').hasMatch(timeStr)) {
      return int.tryParse(timeStr) ?? 0;
    }

    // Handles formatted timestamps like "?t=1m34s" or "?t=1h2m30s"
    int totalSeconds = 0;
    final hMatch = RegExp(r'(\d+)h').firstMatch(timeStr);
    final mMatch = RegExp(r'(\d+)m').firstMatch(timeStr);
    final sMatch = RegExp(r'(\d+)s').firstMatch(timeStr);

    if (hMatch != null) totalSeconds += int.parse(hMatch.group(1)!) * 3600;
    if (mMatch != null) totalSeconds += int.parse(mMatch.group(1)!) * 60;
    if (sMatch != null) totalSeconds += int.parse(sMatch.group(1)!);

    return totalSeconds;
  }
}

class YoutubeVideoData {
  final String? videoId;
  final int startSeconds;
  YoutubeVideoData({required this.videoId, required this.startSeconds});
}