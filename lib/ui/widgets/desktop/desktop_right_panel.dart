import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit/media_kit.dart' show Media;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';

import '../../../providers/player_provider.dart';
import '../../../services/audio_service.dart';
import '../cached_artwork.dart';

class DesktopRightPanel extends StatelessWidget {
  final bool cariActive;
  final VoidCallback? onCariFinished;
  const DesktopRightPanel({super.key, this.cariActive = false, this.onCariFinished});

  String _formatArtists(String raw) {
    final parts = raw.split(RegExp(r'\s*/\s*'));
    if (parts.length <= 1) return raw.trim();
    final limited = parts.take(3).map((e) => e.trim()).toList();
    final joined = limited.join(' · ');
    return parts.length > 3 ? '$joined...' : joined;
  }

  @override
  Widget build(BuildContext context) {
    if (cariActive) {
      return _CariPanel(onFinished: onCariFinished);
    }
    final player = context.watch<PlayerProvider>();
    final current = player.currentTrack;
    final queue = player.queue;
    final nextIndex = player.currentIndex + 1;
    final nextTrack =
        (nextIndex >= 0 && nextIndex < queue.length) ? queue[nextIndex] : null;

    final title = current == null
        ? 'Reproduciendo'
        : (current.album.isNotEmpty ? current.album : current.title);

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: NexoraColors.surfaceAlt,
        border: Border(
          left: BorderSide(color: NexoraColors.border),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexoraColors.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.expand, size: 22, color: NexoraColors.foreground),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: current == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.music,
                          size: 22,
                          color: NexoraColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Sin reproducción',
                          style: TextStyle(color: NexoraColors.muted),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedArtwork(
                          albumArt: current.albumArt,
                          width: double.infinity,
                          height: 280,
                          borderRadius: BorderRadius.circular(12),
                          fallback: Container(
                            width: double.infinity,
                            height: 280,
                            color: NexoraColors.surfaceHover,
                            child: FaIcon(FontAwesomeIcons.music, size: 80, color: NexoraColors.muted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          current.title,
                          style: const TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatArtists(current.artist),
                          style: const TextStyle(
                            color: NexoraColors.mutedStrong,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.album,
                          style: const TextStyle(
                            color: NexoraColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Letra',
                          style: TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: NexoraColors.surfaceHover,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: NexoraColors.border),
                          ),
                          child: const Text(
                            'Letra no disponible\n\nUsa la función de búsqueda de letra\npara obtener las letras de tus canciones',
                            style: TextStyle(
                              color: NexoraColors.muted,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Siguiente canción',
                          style: TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (nextTrack != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NexoraColors.surfaceHover,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: NexoraColors.border),
                            ),
                            child: Row(
                              children: [
                                CachedArtwork(
                                  albumArt: nextTrack.albumArt,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(6),
                                  fallback: Container(
                                    width: 48,
                                    height: 48,
                                    color: NexoraColors.surface,
                                    child: FaIcon(FontAwesomeIcons.music, color: NexoraColors.muted),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nextTrack.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: NexoraColors.foreground,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        nextTrack.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: NexoraColors.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'No hay siguiente canción',
                            style: TextStyle(color: NexoraColors.muted, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


class _CariPanel extends StatefulWidget {
  final VoidCallback? onFinished;
  const _CariPanel({this.onFinished});
  @override
  State<_CariPanel> createState() => _CariPanelState();
}

class _CariPanelState extends State<_CariPanel> {
  late final Player _player;
  List<String> _tracks = [];
  int _currentIndex = 0;
  bool _playing = false;
  StreamSubscription<bool>? _completedSub;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _completedSub = _player.stream.completed.listen((completed) {
      if (!completed) return;
      _advance();
    });
    _player.stream.playing.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final regex = RegExp(r'"(assets/voz/[^"]+)"');
      final matches = regex.allMatches(manifest).map((m) => m.group(1)!).toList();
      matches.sort();
      _tracks = matches;
      if (_tracks.isNotEmpty) {
        await _playIndex(0);
      } else {
        widget.onFinished?.call();
      }
    } catch (e) {
      debugPrint('Cari voice load error: $e');
    }
  }

  Future<void> _playIndex(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    _currentIndex = index;
    try {
      final bytes = await rootBundle.load(_tracks[index]);
      final data = bytes.buffer.asUint8List();
      final media = await Media.memory(data);
      await _player.open(media, play: true);
      if (mounted) setState(() => _playing = true);
    } catch (e) {
      debugPrint('Cari play error: $e');
    }
  }

  void _advance() {
    if (_tracks.isEmpty) {
      widget.onFinished?.call();
      return;
    }
    final next = _currentIndex + 1;
    if (next >= _tracks.length) {
      _player.stop();
      widget.onFinished?.call();
      return;
    }
    _playIndex(next);
  }

  void _togglePlayPause() {
    if (_playing) {
      _player.pause();
    } else {
      if (_tracks.isNotEmpty && _player.state.playlist.medias.isEmpty) {
        _playIndex(_currentIndex);
      } else {
        _player.play();
      }
    }
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: const Color(0xFF800020),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Cari',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.expand, size: 16, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icons/Logo-Cari.png',
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 280,
                        color: const Color(0xFF600018),
                        child: const Icon(Icons.smart_toy, size: 80, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cari',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu asistente de IA',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: IconButton(
                      icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 48, color: Colors.white),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
