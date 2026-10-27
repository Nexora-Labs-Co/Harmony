import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:watcher/watcher.dart';

import '../providers/library_provider.dart';

class MusicWatcher {
  MusicWatcher._internal();
  static final MusicWatcher instance = MusicWatcher._internal();

  StreamSubscription<WatchEvent>? _subscription;
  Timer? _debounce;
  String? _watchedPath;

  bool get isWatching => _subscription != null;

  Future<void> start(String directory, LibraryProvider library) async {
    if (_watchedPath == directory && isWatching) return;
    await stop();

    final dir = Directory(directory);
    if (!await dir.exists()) return;

    _watchedPath = directory;
    final watcher = DirectoryWatcher(directory);

    _subscription = watcher.events.listen((event) {
      final path = event.path.toLowerCase();
      const audioExts = ['.mp3', '.flac', '.wav', '.ogg', '.m4a', '.opus', '.aac'];
      final isAudio = audioExts.any((e) => path.endsWith(e));
      if (!isAudio) return;

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        debugPrint('MusicWatcher: cambio detectado -> rescaneando');
        library.scanLibrary(directory);
      });
    });

    debugPrint('MusicWatcher: observando $directory');
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _debounce?.cancel();
    _debounce = null;
    _watchedPath = null;
  }
}