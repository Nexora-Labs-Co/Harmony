import 'package:flutter/material.dart';

import 'package:harmony/src/services/favorites_store.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayerService.instance,
      builder: (context, _) {
        final player = PlayerService.instance;
        final track = player.currentTrack;
        final bg = const Color(0xFF121212);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const Spacer(),
                      const Text('Reproduciendo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 12))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: track != null
                                ? CachedArtwork(
                                    path: track.coverPath,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fallback: Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 64, color: Colors.white)),
                                  )
                                : Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 64, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(track?.title ?? 'Sin pista', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(track?.artist ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),
                  Slider(
                    value: player.duration.inMilliseconds > 0
                        ? player.position.inMilliseconds.clamp(0, player.duration.inMilliseconds).toDouble()
                        : 0,
                    max: player.duration.inMilliseconds > 0 ? player.duration.inMilliseconds.toDouble() : 1,
                    onChanged: (v) => player.seek(Duration(milliseconds: v.round())),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(player.position), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(_fmt(player.duration), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                        onPressed: player.previous,
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: player.togglePlayPause,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Center(
                            child: Icon(
                              player.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: bg,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                        onPressed: player.next,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          (track != null && FavoritesStore.instance.paths.value.contains(track.path)) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (track != null) FavoritesStore.instance.toggle(track);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shuffle, color: player.shuffle ? Colors.white : Colors.white54),
                        onPressed: player.toggleShuffle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.lyrics, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LyricsScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.maybePop(context)),
                  const Expanded(child: Text('Letra', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: Center(
                  child: Text('Lo sentimos, todavía no sabemos la letra', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

