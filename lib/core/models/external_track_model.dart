class ExternalTrackModel {
  const ExternalTrackModel({
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
