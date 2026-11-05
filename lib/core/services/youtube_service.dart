class YouTubeTrack {
  const YouTubeTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.duration = 0,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String artist;
  final int duration;
  final String? thumbnailUrl;
}

class YouTubeService {
  YouTubeService._();
  static final instance = YouTubeService._();

  Future<List<YouTubeTrack>> search(String query) async {
    return List.generate(
      8,
      (i) => YouTubeTrack(
        id: 'yt_${i + 1}',
        title: 'Nuevo lanzamiento ${i + 1}',
        artist: 'Artista ${i + 1}',
        thumbnailUrl: null,
      ),
    );
  }
}
