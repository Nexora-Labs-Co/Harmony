class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
  });

  int get trackCount => trackIds.length;
}
