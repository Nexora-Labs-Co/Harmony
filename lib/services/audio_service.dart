import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:shared_preferences/shared_preferences.dart';

import '../bridge/bridge_generated.dart';
import 'rust_ffi.dart';
import 'youtube_service.dart';

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
  Stream<bool> get completedStream => _player.stream.completed;
  bool get initialized => _initialized;
  bool get playing => _playing;
  double get volume => _volume;
  Track? get currentTrack => _currentTrack;
  Duration get position => _position;
  Duration get duration => _duration;

  void initialize() {
    _ffi.load();
    MediaKit.ensureInitialized();
    // Restaurar volumen guardado
    SharedPreferences.getInstance().then((prefs) {
      final v = prefs.getDouble('volume');
      if (v != null) _volume = v.clamp(0.0, 1.0);
      _player.setVolume(_volume * 100);
    });
    _player.stream.playing.listen((isPlaying) {
      _playing = isPlaying;
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
    _player.stream.error.listen((e) {
      debugPrint('AudioService player error: $e');
    });
    _player.stream.log.listen((e) {
      debugPrint('AudioService player log: $e');
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

  /// Reproduce una URL directa (ej. stream de YouTube) usando media_kit.
  bool _isPlayingUrl = false;

  Future<bool> playUrl(String url, {String? title, String? artist, String? thumbnailUrl, int durationMs = 0}) async {
    if (_isPlayingUrl) {
      debugPrint('AudioService.playUrl: already playing a URL, ignoring.');
      return false;
    }
    _isPlayingUrl = true;
    debugPrint('AudioService.playUrl: $url');
    try {
      await _player.stop();
      _currentTrack = nexoraCreateLocalTrack(
        id: 'yt-${url.hashCode}',
        title: title ?? 'YouTube',
        artist: artist ?? 'YouTube',
        album: 'YouTube',
        albumArt: thumbnailUrl,
        filePath: '',
        durationMs: durationMs,
      );
      await _player.open(
        Media(
          url,
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Referer': 'https://www.youtube.com/',
          },
        ),
        play: true,
      );
      await _player.play();
      debugPrint('AudioService.playUrl: playing=${_player.state.playing} duration=${_player.state.duration}');
      _playing = true;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('ERROR CRITICO EN AudioService.playUrl: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _isPlayingUrl = false;
    }
  }

  Future<bool> loadTrack(Track track) async {
    try {
      _currentTrack = track;
      if (track.trackType == TrackType.Remote || track.source == 'youtube') {
        final url = await YouTubeService.instance.getStreamUrl(track.id);
        if (url == null) return false;
        await _player.open(
          Media(
            url,
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': '*/*',
              'Referer': 'https://www.youtube.com/',
            },
          ),
          play: true,
        );
        _playing = true;
        notifyListeners();
        return true;
      }
      final path = (track.path != null && track.path!.isNotEmpty)
          ? track.path!
          : track.sourceUri.replaceFirst('file://', '');
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_track_path', path);
        prefs.setString('last_track_title', track.title);
        prefs.setString('last_track_artist', track.artist);
        prefs.setInt('last_track_duration', track.durationMs);
      });
      await _player.open(Media(path), play: true);
      _playing = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error loading track: $e');
      return false;
    }
  }

  Future<bool> playTrack(Track track) => loadTrack(track);

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

  void togglePlayPause() => _playing ? pause() : play();

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    await _player.setVolume(clamped * 100);
    _volume = clamped;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setDouble('volume', clamped));
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    notifyListeners();
  }

  double getVolume() => _volume;
  String? getCurrentSource() => _currentTrack?.sourceUri;

  List<Track> scanLibrary(String directory) {
    final tracks = nexoraScanLibrary(directory: directory);
    final enriched = <Track>[];
    for (final t in tracks) {
      final path = t.path ?? t.sourceUri.replaceFirst('file://', '');
      int ms = t.durationMs;
      if (ms == 0 && path.isNotEmpty) {
        try { ms = _ffi.durationMs(path); } catch (_) {}
      }
      String artist = t.artist;
      String album = t.album;
      String title = t.title;
      String? artwork = t.albumArt;
      if (path.isNotEmpty) {
        try { artist = _ffi.artist(path); } catch (_) {}
        try { album = _ffi.album(path); } catch (_) {}
        try { title = _ffi.title(path, t.title); } catch (_) {}
        try { artwork = _ffi.artworkBase64(path); } catch (_) {}
      }
      if (artist.isEmpty) artist = 'Artista desconocido';
      enriched.add(nexoraCreateLocalTrack(
        id: t.id,
        title: title,
        artist: artist,
        album: album,
        albumArt: artwork,
        filePath: path,
        durationMs: ms > 0 ? ms : t.durationMs,
      ));
    }
    return enriched;
  }
}
