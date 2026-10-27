import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bridge/bridge_generated.dart';
import '../services/audio_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioService _audio = AudioService.instance;
  StreamSubscription<bool>? _completedSub;

  Track? get currentTrack => _audio.currentTrack;
  bool get isPlaying => _audio.playing;
  double get volume => _audio.volume;
  Duration get position => _audio.position;
  Duration get duration => _audio.duration;

  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.none;

  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get shuffle => _shuffle;
  PlayerRepeatMode get repeatMode => _repeatMode;

  PlayerProvider() {
    _audio.addListener(_onAudioChanged);
    _completedSub = _audio.completedStream.listen((completed) {
      if (!completed) return;
      _handleTrackCompleted();
    });
  }

  void _onAudioChanged() => notifyListeners();

  void _handleTrackCompleted() {
    if (_queue.isEmpty) return;
    if (_repeatMode == PlayerRepeatMode.one) {
      if (_currentIndex >= 0 && _currentIndex < _queue.length) {
        _audio.playTrack(_queue[_currentIndex]);
      }
      return;
    }
    if (_shuffle) {
      if (_queue.length > 1) {
        int next = _currentIndex;
        while (next == _currentIndex) {
          next = DateTime.now().millisecondsSinceEpoch % _queue.length;
        }
        _currentIndex = next;
      }
    } else {
      _currentIndex++;
    }
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _audio.playTrack(_queue[_currentIndex]);
    } else {
      if (_repeatMode == PlayerRepeatMode.all && _queue.isNotEmpty) {
        _currentIndex = 0;
        _audio.playTrack(_queue[_currentIndex]);
      } else {
        _currentIndex = -1;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _audio.removeListener(_onAudioChanged);
    super.dispose();
  }

  Future<void> playTrack(Track track) async => _audio.playTrack(track);
  void play() => _audio.play();
  void pause() => _audio.pause();
  void stop() => _audio.stop();
  void togglePlayPause() => _audio.togglePlayPause();
  void setVolume(double vol) => _audio.setVolume(vol);
  Future<void> seek(Duration pos) => _audio.seek(pos);

  void next() {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      int next = _currentIndex;
      while (_queue.length > 1 && next == _currentIndex) {
        next = DateTime.now().millisecondsSinceEpoch % _queue.length;
      }
      _currentIndex = next;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      playTrack(_queue[_currentIndex]);
    }
    notifyListeners();
  }

  void previous() {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      playTrack(_queue[_currentIndex]);
    }
    notifyListeners();
  }

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _queue = tracks;
    _currentIndex = startIndex;
    if (tracks.isNotEmpty && startIndex < tracks.length) {
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
