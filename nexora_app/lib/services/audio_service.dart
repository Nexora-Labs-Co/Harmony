import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import '../bridge/bridge_generated.dart';
import 'rust_ffi.dart';

class AudioService extends ChangeNotifier {
  static final AudioService instance = AudioService._internal();
  factory AudioService() => instance;
  AudioService._internal();

  final RustFfi _ffi = RustFfi.instance;
  Player? _playerInstance;
  Player get _player {
    _playerInstance ??= Player();
    return _playerInstance!;
  }

  bool _initialized = false;
  bool _playing = false;
  double _volume = 1.0;
  Track? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Player get player => _player;

  bool get initialized => _initialized;
  bool get playing => _playing;
  double get volume => _volume;
  Track? get currentTrack => _currentTrack;
  Duration get position => _position;
  Duration get duration => _duration;

  void initialize() {
    _ffi.load();
    MediaKit.ensureInitialized();
    _player.stream.playing.listen((playing) {
      _playing = playing;
      notifyListeners();
    });
    _player.stream.position.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _player.stream.duration.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
    _player.stream.volume.listen((vol) {
      _volume = (vol / 100.0).clamp(0.0, 1.0);
      notifyListeners();
    });
    _initialized = true;
    notifyListeners();
  }

  void teardown() {
    _player.dispose();
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

  Future<bool> loadTrack(Track track) async {
    try {
      _currentTrack = track;
      String path = '';
      if (track.path != null && track.path!.isNotEmpty) {
        path = track.path!;
      } else {
        path = track.sourceUri.replaceFirst('file://', '');
      }
      await _player.open(Media(path), play: true);
      _playing = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error loading track: $e');
      return false;
    }
  }

  Future<void> play() async {
    await _player.play();
    _playing = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    _playing = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _playing = false;
    _position = Duration.zero;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_playing) {
      pause();
    } else {
      play();
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    await _player.setVolume(clamped * 100);
    _volume = clamped;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  double getVolume() => _volume;

  String? getCurrentSource() => _currentTrack?.sourceUri;

  List<Track> scanLibrary(String directory) {
    final tracks = nexoraScanLibrary(directory: directory);
    final enriched = <Track>[];
    for (final t in tracks) {
      int ms = t.durationMs;
      if (ms == 0 && t.path != null && t.path!.isNotEmpty) {
        try { ms = _ffi.durationMs(t.path!); } catch (_) {}
      }
      enriched.add(nexoraCreateLocalTrack(
        id: t.id,
        title: t.title,
        artist: t.artist,
        album: t.album,
        albumArt: t.albumArt,
        filePath: t.path ?? t.sourceUri.replaceFirst('file://', ''),
        durationMs: ms > 0 ? ms : t.durationMs,
      ));
    }
    return enriched;
  }
}
