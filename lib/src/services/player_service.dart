import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/recent_tracks_service.dart';

class PlayerService extends ChangeNotifier {
  PlayerService._();
  static final instance = PlayerService._();

  final AudioPlayer _player = AudioPlayer();

  List<LocalTrack> _queue = [];
  int _index = 0;
  bool _isPlaying = false;

  LocalTrack? get currentTrack => _queue.isEmpty ? null : _queue[_index.clamp(0, _queue.length - 1)];
  bool get isPlaying => _isPlaying;

  Future<void> _playCurrent() async {
    final track = currentTrack;
    if (track == null) return;
    if (track.path.isNotEmpty) {
      try {
        if (track.path.startsWith('http')) {
          await _player.setAudioSource(
            AudioSource.uri(
              Uri.parse(track.path),
              headers: const {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Referer': 'https://www.youtube.com/',
              },
            ),
          );
        } else {
          await _player.setFilePath(track.path);
        }
        await _player.play();
        _isPlaying = true;
      } catch (e) {
        _isPlaying = false;
      }
    } else {
      _isPlaying = true;
    }
    if (currentTrack != null) RecentTracksService.instance.record(currentTrack!);
    notifyListeners();
  }

  void play(LocalTrack track, {List<LocalTrack>? queue}) {
    if (queue != null && queue.isNotEmpty) {
      _queue = List<LocalTrack>.from(queue);
      _index = _queue.indexOf(track);
      if (_index < 0) _index = 0;
    } else {
      _queue = [track];
      _index = 0;
    }
    _playCurrent();
  }

  void playQueue(List<LocalTrack> queue, int startIndex) {
    if (queue.isEmpty) return;
    _queue = List<LocalTrack>.from(queue);
    _index = startIndex.clamp(0, queue.length - 1);
    _playCurrent();
  }

  void togglePlay() {
    if (_isPlaying) {
      _player.pause();
      _isPlaying = false;
    } else {
      _player.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty) return;
    _index = (_index + 1) % _queue.length;
    _playCurrent();
  }

  void previous() {
    if (_queue.isEmpty) return;
    _index = (_index - 1 + _queue.length) % _queue.length;
    _playCurrent();
  }
}