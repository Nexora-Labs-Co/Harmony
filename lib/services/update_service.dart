import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Actualizador sencillo (Linux + Windows) sin dependencias de dpkg/apt.
/// Consulta un endpoint JSON con la version mas reciente y, si es mayor,
/// descarga e instala el paquete correspondiente.
class UpdateService {
  UpdateService._internal();
  static final UpdateService instance = UpdateService._internal();

  /// Endpoint que devuelve JSON: {"version":"26.10.28","url":"https://.../harmony_26.10.28_amd64.deb"}
  static const String _endpoint = 'https://example.com/harmony/version.json';

  String _currentVersion = '26.10.27';

  void setcurrentVersion(String v) => _currentVersion = v;

  /// Comprueba si hay una actualizacion disponible.
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final res = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final remote = data['version'] as String?;
      if (remote == null) return null;
      if (_compareVersions(remote, _currentVersion) > 0) {
        return data;
      }
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
        // pkexec solicita privilegios de forma grafica
        final result = await Process.run('pkexec', ['dpkg', '-i', file.path]);
        debugPrint('dpkg result: ${result.exitCode} ${result.stderr}');
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

  /// Compara versiones "x.y.z" (positivo si a > b).
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
