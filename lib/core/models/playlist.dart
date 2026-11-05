class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.trackIds = const [],
    this.coverImagePath,
  });

  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final String? coverImagePath;
}
