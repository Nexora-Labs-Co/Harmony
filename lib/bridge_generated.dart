import 'dart:io';

enum TrackType { Local, Remote }

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArt;
  final String sourceUri;
  final int durationMs;
  final TrackType trackType;
  final String? path;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    required this.sourceUri,
    required this.durationMs,
    required this.trackType,
    this.path,
  });
}

class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final int createdAt;
  final int updatedAt;
  final String? coverImagePath;

  String? get coverPath => coverImagePath;
  String? get coverUrl => coverImagePath;
  List<String> get songs => trackIds;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImagePath,
  });
}

bool nexoraInit() => true;
void nexoraTeardown() {}
Track nexoraCreateLocalTrack({
  required String id,
  required String title,
  required String artist,
  required String album,
  String? albumArt,
  required String filePath,
  required int durationMs,
}) {
  return Track(
    id: id,
    title: title,
    artist: artist,
    album: album,
    albumArt: albumArt,
    sourceUri: 'file://$filePath',
    durationMs: durationMs,
    trackType: TrackType.Local,
    path: filePath,
  );
}
bool nexoraLoadTrack({required Track track}) => true;
void nexoraPlay() {}
void nexoraPause() {}
void nexoraStop() {}
bool nexoraIsPlaying() => false;
bool nexoraIsInitialized() => true;
void nexoraSetVolume({required double volume}) {}
double nexoraGetVolume() => 1.0;
String? nexoraGetCurrentSource() => null;
List<Track> nexoraScanLibrary({required String directory}) {
  final result = <Track>[];
  try {
    final dir = Directory(directory);
    if (!dir.existsSync()) return result;
    final audioExtensions = ['.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.opus'];
    int counter = 0;
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File) {
        final path = entity.path;
        final ext = path.substring(path.lastIndexOf('.')).toLowerCase();
        if (audioExtensions.contains(ext)) {
          counter++;
          final fileName = path.split(Platform.pathSeparator).last;
          final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
          result.add(Track(
            id: 'local-$counter',
            title: nameWithoutExt,
            artist: 'Artista desconocido',
            album: 'Álbum desconocido',
            sourceUri: 'file://$path',
            durationMs: 0,
            trackType: TrackType.Local,
            path: path,
          ));
        }
      }
    }
  } catch (_) {}
  return result;
}
String nexoraGetTrackTypeLabel({required TrackType trackType}) {
  return trackType == TrackType.Local ? 'Local' : 'Remota';
}

// Favoritos
void nexoraAddFavorite({required String trackId}) {}
void nexoraRemoveFavorite({required String trackId}) {}
bool nexoraToggleFavorite({required String trackId}) => false;
bool nexoraIsFavorite({required String trackId}) => false;
List<String> nexoraGetFavoriteIds() => [];
List<Track> nexoraGetFavorites({required List<Track> tracks}) => [];

// Playlists
Playlist nexoraCreatePlaylist({required String name, required String description}) {
  return Playlist(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
    description: description,
    trackIds: [],
    createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    coverImagePath: null,
  );
}
List<Playlist> nexoraGetAllPlaylists() => [];
Playlist? nexoraGetPlaylist({required String id}) => null;
bool nexoraAddTrackToPlaylist({required String playlistId, required String trackId}) => true;
bool nexoraRemoveTrackFromPlaylist({required String playlistId, required String trackId}) => true;
bool nexoraDeletePlaylist({required String playlistId}) => true;
bool nexoraRenamePlaylist({required String playlistId, required String newName}) => true;
List<Track> nexoraGetPlaylistTracks({required String playlistId, required List<Track> allTracks}) => [];

// Búsqueda
List<Track> nexoraSearchTracks({required String query, required List<Track> tracks}) {
  if (query.isEmpty) return tracks;
  final q = query.toLowerCase();
  return tracks.where((t) => t.title.toLowerCase().contains(q) || t.artist.toLowerCase().contains(q) || t.album.toLowerCase().contains(q)).toList();
}
List<Track> nexoraSearchByArtist({required String artist, required List<Track> tracks}) {
  final a = artist.toLowerCase();
  return tracks.where((t) => t.artist.toLowerCase().contains(a)).toList();
}
List<Track> nexoraSearchByAlbum({required String album, required List<Track> tracks}) {
  final al = album.toLowerCase();
  return tracks.where((t) => t.album.toLowerCase().contains(al)).toList();
}

