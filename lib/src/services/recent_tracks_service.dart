import 'package:harmony/src/models/local_track.dart';

class RecentTracksService {
  RecentTracksService._();
  static final instance = RecentTracksService._();

  final List<_RecentEntry> _entries = [];

  List<LocalTrack> get recentTracks {
    final cutoff = DateTime.now().subtract(const Duration(hours: 3));
    final filtered = _entries.where((e) => e.playedAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return filtered.map((e) => e.track).toList();
  }

  void record(LocalTrack track) {
    _entries.removeWhere((e) => e.track.path == track.path);
    _entries.insert(0, _RecentEntry(track, DateTime.now()));
  }
}

class _RecentEntry {
  _RecentEntry(this.track, this.playedAt);
  final LocalTrack track;
  final DateTime playedAt;
}

