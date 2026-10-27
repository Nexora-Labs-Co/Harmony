import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

class RustFfi {
  static final RustFfi instance = RustFfi._internal();
  factory RustFfi() => instance;
  RustFfi._internal();

  DynamicLibrary? _lib;
  bool _loaded = false;

  bool get loaded => _loaded;

  // Function pointers
  late final int Function() _init;
  late final void Function() _teardown;
  late final int Function(Pointer<Utf8>) _loadPath;
  late final void Function() _play;
  late final void Function() _pause;
  late final void Function() _stop;
  late final int Function() _isPlaying;
  late final void Function(double) _setVolume;
  late final double Function() _getVolume;
  late final void Function(int) _seek;
  late final int Function(Pointer<Utf8>) _durationMs;
  late final Pointer<Utf8> Function(Pointer<Utf8>) _artist;
  late final Pointer<Utf8> Function(Pointer<Utf8>) _album;
  late final Pointer<Utf8> Function(Pointer<Utf8>) _title;
  late final Pointer<Utf8> Function(Pointer<Utf8>) _artwork;
  late final void Function(Pointer<Utf8>) _freeString;

  bool load() {
    if (_loaded) return true;
    try {
      final soPath = _findLibrary();
      if (soPath == null) {
        debugPrint('Rust library not found');
        return false;
      }
      _lib = DynamicLibrary.open(soPath);
      _init = _lib!.lookupFunction<Int32 Function(), int Function()>('nexora_ffi_init');
      _teardown = _lib!.lookupFunction<Void Function(), void Function()>('nexora_ffi_teardown');
      _loadPath = _lib!.lookupFunction<Int32 Function(Pointer<Utf8>), int Function(Pointer<Utf8>)>('nexora_ffi_load_path');
      _play = _lib!.lookupFunction<Void Function(), void Function()>('nexora_ffi_play');
      _pause = _lib!.lookupFunction<Void Function(), void Function()>('nexora_ffi_pause');
      _stop = _lib!.lookupFunction<Void Function(), void Function()>('nexora_ffi_stop');
      _isPlaying = _lib!.lookupFunction<Int32 Function(), int Function()>('nexora_ffi_is_playing');
      _setVolume = _lib!.lookupFunction<Void Function(Double), void Function(double)>('nexora_ffi_set_volume');
      _getVolume = _lib!.lookupFunction<Double Function(), double Function()>('nexora_ffi_get_volume');
      _seek = _lib!.lookupFunction<Void Function(Uint64), void Function(int)>('nexora_ffi_seek');
      _durationMs = _lib!.lookupFunction<Uint64 Function(Pointer<Utf8>), int Function(Pointer<Utf8>)>('nexora_ffi_duration_ms');
      _artist = _lib!.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('nexora_ffi_artist');
      _album = _lib!.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('nexora_ffi_album');
      _title = _lib!.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('nexora_ffi_title');
      _artwork = _lib!.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('nexora_ffi_artwork_base64');
      _freeString = _lib!.lookupFunction<Void Function(Pointer<Utf8>), void Function(Pointer<Utf8>)>('nexora_ffi_free_string');
      _init();
      _loaded = true;
      return true;
    } catch (e) {
      debugPrint('Failed to load Rust library: $e');
      return false;
    }
  }

  String? _findLibrary() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final candidates = <String>[
      '$exeDir/libnexora_core.so',
      'libnexora_core.so',
      '/home/saaarmyx/Desktop/Nexora-Labs-Co/Harmony/nexora_app/rust/target/debug/libnexora_core.so',
      '${Directory.current.path}/rust/target/debug/libnexora_core.so',
    ];
    for (final c in candidates) {
      final f = File(c);
      if (f.existsSync()) return f.absolute.path;
    }
    // Search upwards
    try {
      final dir = Directory.current;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('libnexora_core.so')) {
          return entity.absolute.path;
        }
      }
    } catch (_) {}
    return null;
  }

  int init() => _loaded ? _init() : 0;
  void teardown() { if (_loaded) _teardown(); }
  bool loadPath(String path) {
    if (!_loaded) return false;
    final ptr = path.toNativeUtf8();
    final r = _loadPath(ptr);
    malloc.free(ptr);
    return r == 1;
  }
  void play() { if (_loaded) _play(); }
  void pause() { if (_loaded) _pause(); }
  void stop() { if (_loaded) _stop(); }
  bool isPlaying() => _loaded ? _isPlaying() == 1 : false;
  void setVolume(double v) { if (_loaded) _setVolume(v); }
  double getVolume() => _loaded ? _getVolume() : 1.0;
  void seek(int posMs) { if (_loaded) _seek(posMs); }
  int durationMs(String path) {
    if (!_loaded) return 0;
    final ptr = path.toNativeUtf8();
    final r = _durationMs(ptr);
    malloc.free(ptr);
    return r;
  }

  String _readString(Pointer<Utf8> Function(Pointer<Utf8>) fn, String path, String fallback) {
    if (!_loaded) return fallback;
    final ptr = path.toNativeUtf8();
    final res = fn(ptr);
    malloc.free(ptr);
    if (res == nullptr) return fallback;
    final str = res.toDartString();
    _freeString(res);
    return str.isEmpty ? fallback : str;
  }

  String artist(String path) => _readString(_artist, path, 'Artista desconocido');
  String album(String path) => _readString(_album, path, 'Album desconocido');
  String title(String path, String fallback) => _readString(_title, path, fallback);

  /// Returns raw base64 of cover art, or null if none.
  String? artworkBase64(String path) {
    if (!_loaded) return null;
    final ptr = path.toNativeUtf8();
    final res = _artwork(ptr);
    malloc.free(ptr);
    if (res == nullptr) return null;
    final str = res.toDartString();
    _freeString(res);
    return str.isEmpty ? null : str;
  }
}
