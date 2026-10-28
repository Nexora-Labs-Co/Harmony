import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Actualizador automatico usando GitHub Releases.
/// Consulta la ultima release, descarga el .deb/.exe y lo instala.
class UpdateService {
  UpdateService._internal();
  static final UpdateService instance = UpdateService._internal();

  static const String _repo = 'Nexora-Labs-Co/Harmony';
  static const String _apiUrl = 'https://api.github.com/repos/$_repo/releases/latest';

  String _currentVersion = '26.10.27';

  void setcurrentVersion(String v) => _currentVersion = v;

  /// Comprueba si hay una actualizacion disponible en GitHub Releases.
  /// Devuelve el asset (nombre + url) si hay version mas nueva.
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final res = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String?)?.replaceAll('v', '') ?? '';
      if (tag.isEmpty) return null;

      // Comparar versiones
      if (_compareVersions(tag, _currentVersion) <= 0) return null;

      // Buscar asset compatible (.deb en Linux, .exe en Windows)
      final assets = data['assets'] as List<dynamic>? ?? [];
      String? downloadUrl;
      String? assetName;
      for (final a in assets) {
        final name = a['name'] as String? ?? '';
        if (Platform.isLinux && name.endsWith('.deb')) {
          downloadUrl = a['browser_download_url'] as String?;
          assetName = name;
          break;
        } else if (Platform.isWindows && name.endsWith('.exe')) {
          downloadUrl = a['browser_download_url'] as String?;
          assetName = name;
          break;
        }
      }
      if (downloadUrl == null) return null;

      return {
        'version': tag,
        'url': downloadUrl,
        'name': assetName,
      };
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate error: $e');
    }
    return null;
  }

  /// Descarga e instala la actualizacion.
  Future<bool> downloadAndInstall(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return false;

      final dir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(res.bodyBytes);

      if (Platform.isLinux) {
        // sudo apt install para actualizar sin conflictos
        final result = await Process.run('sudo', ['apt', 'install', '-y', file.path]);
        debugPrint('apt install result: ${result.exitCode} ${result.stderr}');
        return result.exitCode == 0;
      } else if (Platform.isWindows) {
        await Process.start(file.path, [], mode: ProcessStartMode.detached);
        return true;
      }
    } catch (e) {
      debugPrint('UpdateService.downloadAndInstall error: $e');
    }
    return false;
  }

  int _compareVersions(String a, String b) {
    final pa = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final pb = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }
}
