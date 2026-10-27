import 'package:flutter/foundation.dart';
import '../bridge_generated.dart';

class AudioService extends ChangeNotifier {
  bool _initialized = false;
  bool _playing = false;
  double _volume = 1.0;
  Track? _currentTrack;

  bool get initialized => _initialized;
  bool get playing => _playing;
  double get volume => _volume;
  Track? get currentTrack => _currentTrack;

  void initialize() {
    try {
      _initialized = nexoraInit();
      _volume = nexoraGetVolume();
      notifyListeners();
    } catch (e) {
      _initialized = false;
      notifyListeners();
    }
  }

  void teardown() {
    try {
      nexoraTeardown();
    } catch (_) {}
    _initialized = false;
    _playing = false;
    notifyListeners();
  }

  Track createLocalTrack({
    required String id,
    required String title,
    required String artist,
    required String album,
    String? albumArt,
    required String filePath,
    required int durationMs,
  }) {
    return nexoraCreateLocalTrack(
      id: id,
      title: title,
      artist: artist,
      album: album,
      albumArt: albumArt,
      filePath: filePath,
      durationMs: durationMs,
    );
  }

  bool loadTrack(Track track) {
    try {
      final result = nexoraLoadTrack(track: track);
      if (result) {
        _currentTrack = track;
        notifyListeners();
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  void play() {
    try {
      nexoraPlay();
      _playing = nexoraIsPlaying();
      notifyListeners();
    } catch (_) {}
  }

  void pause() {
    try {
      nexoraPause();
      _playing = false;
      notifyListeners();
    } catch (_) {}
  }

  void stop() {
    try {
      nexoraStop();
      _playing = false;
      notifyListeners();
    } catch (_) {}
  }

  void togglePlayPause() {
    if (_playing) {
      pause();
    } else {
      play();
    }
  }

  void setVolume(double volume) {
    try {
      final clamped = volume.clamp(0.0, 1.0);
      nexoraSetVolume(volume: clamped);
      _volume = clamped;
      notifyListeners();
    } catch (_) {}
  }

  String? getCurrentSource() {
    try {
      return nexoraGetCurrentSource();
    } catch (_) {
      return null;
    }
  }

  List<Track> scanLibrary(String directory) {
    try {
      return nexoraScanLibrary(directory: directory);
    } catch (_) {
      return [];
    }
  }
}
```