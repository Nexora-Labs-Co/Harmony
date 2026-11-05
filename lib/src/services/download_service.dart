import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/local_track.dart';

class DownloadService {
  DownloadService._();
  static final instance = DownloadService._();

  static const _modulePath = '/home/saaarmyx/Desktop/NexoraLabsCo/Modules/harmony-media-downloader/harmony_downloader/download_playlist.py';

  Future<List<String>> downloadPlaylist(List<LocalTrack> tracks) async {
    final module = File(_modulePath);
    if (!module.existsSync()) return [];

    final outDir = await getApplicationDocumentsDirectory();
    final playlistDir = Directory(p.join(outDir.path, 'Harmony', 'downloads'));
    await playlistDir.create(recursive: true);

    final queries = tracks.map((t) => t.title).where((s) => s.trim().isNotEmpty).toList();
    if (queries.isEmpty) return [];

    try {
      final res = await Process.run('python3', [module.path, playlistDir.path, ...queries]);
      if (res.exitCode != 0) return [];
      final data = (res.stdout as String).trim();
      if (!data.startsWith('[')) return [];
      final list = jsonDecode(data) as List;
      return list
          .whereType<Map>()
          .map((e) => e['file_path']?.toString())
          .whereType<String>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}

