import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/local_track.dart';

class LocalMusicService {
  LocalMusicService._();
  static final instance = LocalMusicService._();

  List<LocalTrack>? _cached;
  Future<List<LocalTrack>>? _inflight;

  static const _audioExtensions = {
    '.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.opus', '.wma',
  };

  Future<List<LocalTrack>> scan() async {
    if (_cached != null) return _cached!;
    if (_inflight != null) return _inflight!;
    _inflight = _doScan();
    final result = await _inflight!;
    _cached = result;
    _inflight = null;
    return result;
  }

  Future<List<LocalTrack>> _doScan() async {
    try {
      await MetadataGod.initialize();
    final roots = <String>['/home/saaarmyx/Music/Harmony'];
    // Android (if available)
    roots.add('/storage/emulated/0/Music/Harmony');
    roots.add('/sdcard/Music/Harmony');

    final files = <File>[];
    for (final root in roots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_audioExtensions.contains(ext)) files.add(entity);
        }
      }
    }

    final tracks = <LocalTrack>[];
    for (final file in files) {
      try {
        final meta = await MetadataGod.readMetadata(file: file.path);
        String? coverPath;
        final pic = meta.picture;
        if (pic != null && pic.data.isNotEmpty) {
          final tempDir = await getTemporaryDirectory();
          final coverFile = File(p.join(tempDir.path, 'cover_${file.uri.pathSegments.last}.jpg'));
          await coverFile.writeAsBytes(pic.data, flush: true);
          coverPath = coverFile.path;
        }
        tracks.add(LocalTrack(
          path: file.path,
          title: (meta.title != null && meta.title!.trim().isNotEmpty) ? meta.title! : p.basenameWithoutExtension(file.path),
          artist: (meta.artist != null && meta.artist!.trim().isNotEmpty) ? meta.artist! : 'Artista desconocido',
          album: meta.album ?? '',
          durationMs: (meta.durationMs ?? 0).toInt(),
          coverPath: coverPath,
        ));
      } catch (_) {
        tracks.add(LocalTrack(
          path: file.path,
          title: p.basenameWithoutExtension(file.path),
          artist: 'Artista desconocido',
        ));
      }
    }
    return tracks;
    } catch (_) {
      return [];
    }
  }
}

