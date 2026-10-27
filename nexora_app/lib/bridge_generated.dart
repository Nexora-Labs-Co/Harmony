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
List<Track> nexoraScanLibrary({required String directory}) => [];
String nexoraGetTrackTypeLabel({required TrackType trackType}) {
  return trackType == TrackType.Local ? 'Local' : 'Remota';
}
