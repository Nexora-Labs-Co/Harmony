class YtTrack {
  const YtTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.thumbnailUrl,
    this.durationSeconds = 0,
    this.streamUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String? streamUrl;
}
