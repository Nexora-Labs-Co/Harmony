import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';
import '../services/audio_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService.instance;
  
  Track? _currentTrack;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _volume = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.none;

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get volume => _volume;
  Duration get position => _position;
  Duration get duration => _duration;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get shuffle => _shuffle;
  PlayerRepeatMode get repeatMode => _repeatMode;

  PlayerProvider() {
    _volume = _audioService.getVolume();
  }

  void playTrack(Track track) {
    _audioService.loadTrack(track);
    _audioService.play();
    _currentTrack = track;
    _isPlaying = true;
    _isPaused = false;
    _duration = Duration(milliseconds: track.durationMs);
    notifyListeners();
  }

  void play() {
    _audioService.play();
    _isPlaying = true;
    _isPaused = false;
    notifyListeners();
  }

  void pause() {
    _audioService.pause();
    _isPlaying = false;
    _isPaused = true;
    notifyListeners();
  }

  void stop() {
    _audioService.stop();
    _isPlaying = false;
    _isPaused = false;
    _position = Duration.zero;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void setVolume(double vol) {
    final clamped = vol.clamp(0.0, 1.0);
    _audioService.setVolume(clamped);
    _volume = clamped;
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      // Simple shuffle
      _currentIndex = (_currentIndex + 1) % _queue.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      playTrack(_queue[_currentIndex]);
    }
  }

  void previous() {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      playTrack(_queue[_currentIndex]);
    }
  }

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _queue = tracks;
    _currentIndex = startIndex;
    if (tracks.isNotEmpty) {
      playTrack(tracks[startIndex]);
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case PlayerRepeatMode.none:
        _repeatMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.none;
        break;
    }
    notifyListeners();
  }
}

enum PlayerRepeatMode { none, all, one }
