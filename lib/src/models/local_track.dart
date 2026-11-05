class LocalTrack {
  const LocalTrack({
    required this.path,
    required this.title,
    required this.artist,
    this.album = '',
    this.durationMs = 0,
    this.coverPath,
  });

  final String path;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? coverPath;
}

