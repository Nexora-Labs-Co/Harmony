class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.durationMs = 0,
    this.albumArt,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? albumArt;
}
