import 'dart:async';
import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';
import 'rust_ffi.dart';

class AudioService extends ChangeNotifier {
  static final AudioService instance = AudioService._internal();
  factory AudioService() => instance;
  AudioService._internal();

  final RustFfi _ffi = RustFfi.instance;

  bool _initialized = false;
  bool _playing = false;
  double _volume = 1.0;
  Track? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _positionTimer;

  bool get initialized => _initialized;
  bool get playing => _playing;
  double get volume => _volume;
  Track? get currentTrack => _currentTrack;
  Duration get position => _position;
  Duration get duration => _duration;

  void initialize() {
    final ok = _ffi.load();
    _initialized = ok;
    if (ok) {
      _volume = _ffi.getVolume();
    }
    notifyListeners();
  }

  void teardown() {
    _ffi.teardown();
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
      _currentTrack = track;
      _duration = Duration(milliseconds: track.durationMs);
      _position = Duration.zero;
      String path = '';
      if (track.path != null && track.path!.isNotEmpty) {
        path = track.path!;
      } else {
        path = track.sourceUri.replaceFirst('file://', '');
      }
      final ok = _ffi.loadPath(path);
      if (ok) {
        _ffi.play();
        _playing = true;
        _startPositionTimer();
      }
      notifyListeners();
      return ok;
    } catch (e) {
      debugPrint('Error loading track: $e');
      return false;
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_playing && _currentTrack != null) {
        final newPos = _position + const Duration(milliseconds: 250);
        if (newPos <= _duration || _duration == Duration.zero) {
          _position = newPos;
        } else {
          _position = _duration;
          // auto next? leave as is
        }
        notifyListeners();
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void play() {
    _ffi.play();
    _playing = true;
    _startPositionTimer();
    notifyListeners();
  }

  void pause() {
    _ffi.pause();
    _playing = false;
    _stopPositionTimer();
    notifyListeners();
  }

  void stop() {
    _ffi.stop();
    _playing = false;
    _position = Duration.zero;
    _stopPositionTimer();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_playing) {
      pause();
    } else {
      play();
    }
  }

  void setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    _ffi.setVolume(clamped);
    _volume = clamped;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    _ffi.seek(position.inMilliseconds);
    _position = position;
    notifyListeners();
  }

  double getVolume() => _volume;

  String? getCurrentSource() => _currentTrack?.sourceUri;

  List<Track> scanLibrary(String directory) => nexoraScanLibrary(directory: directory);
}
