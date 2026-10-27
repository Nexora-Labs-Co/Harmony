import '../bridge/bridge_generated.dart';

class TrackModel {
  final Track track;
  bool isFavorite;

  TrackModel({
    required this.track,
    this.isFavorite = false,
  });

  String get id => track.id;
  String get title => track.title;
  String get artist => track.artist;
  String get album => track.album;
  String? get albumArt => track.albumArt;
  String get sourceUri => track.sourceUri;
  int get durationMs => track.durationMs;
  TrackType get trackType => track.trackType;
  String? get path => track.path;

  String get durationFormatted {
    final duration = Duration(milliseconds: durationMs);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
