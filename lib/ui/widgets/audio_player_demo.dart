import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../services/audio_service.dart';
import '../../services/rust_ffi.dart';

/// ============================================================
/// EJEMPLO COMPLETO: consumo del AudioService en la UI
/// ============================================================
/// Muestra:
///  1. Slider de progreso con seek funcional (position / duration)
///  2. Control de volumen real (0..1 → 0..100 en media_kit)
///  3. Botones Play/Pause sincronizados con el estado
///  4. Duración previa en la lista usando lofty (nexora_ffi_duration_ms)
class AudioPlayerDemo extends StatelessWidget {
  const AudioPlayerDemo({super.key});

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reproductor (demo)')),
      body: Column(
        children: [
          // ── Lista con duración previa (lofty) ────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, i) {
                final path = '/home/user/Music/track_$i.mp3';
                final ms = RustFfi.instance.durationMs(path); // lofty FFI
                final dur = Duration(milliseconds: ms);

                return ListTile(
                  leading: FaIcon(FontAwesomeIcons.music),
                  title: Text('Pista $i'),
                  subtitle: Text('Duración: ${_fmt(dur)}'),
                  trailing: IconButton(
                    icon: FaIcon(FontAwesomeIcons.play),
                    onPressed: () {
                      final track = AudioService.instance.createLocalTrack(
                        id: 'demo-$i',
                        title: 'Pista $i',
                        artist: 'Artista',
                        album: 'Álbum',
                        filePath: path,
                        durationMs: ms,
                      );
                      player.playTrack(track);
                    },
                  ),
                );
              },
            ),
          ),

          // ── Barra de reproducción ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Título
                Text(
                  player.currentTrack?.title ?? 'Sin reproducción',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                // ── 1. Slider de progreso + seek ────────────────────────────
                Row(
                  children: [
                    Text(_fmt(player.position),
                        style: Theme.of(context).textTheme.bodySmall),
                    Expanded(
                      child: Slider(
                        value: player.duration.inMilliseconds > 0
                            ? player.position.inMilliseconds.toDouble().clamp(
                                0, player.duration.inMilliseconds.toDouble())
                            : 0.0,
                        max: player.duration.inMilliseconds > 0
                            ? player.duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (v) => player.seek(
                          Duration(milliseconds: v.toInt()),
                        ),
                      ),
                    ),
                    Text(_fmt(player.duration),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),

                // ── 3. Botones Play/Pause ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: FaIcon(player.isPlaying
                          ? FontAwesomeIcons.circlePause
                          : FontAwesomeIcons.circlePlay),
                      iconSize: 48,
                      onPressed: () => player.togglePlayPause(),
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.stop),
                      iconSize: 32,
                      onPressed: () => player.stop(),
                    ),
                  ],
                ),

                // ── 2. Volumen real (0..1 → 0..100) ────────────────────────
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.volumeLow),
                    Expanded(
                      child: Slider(
                        value: player.volume, // 0.0 .. 1.0
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) => player.setVolume(v),
                      ),
                    ),
                    FaIcon(FontAwesomeIcons.volumeHigh),
                    Text('${(player.volume * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
