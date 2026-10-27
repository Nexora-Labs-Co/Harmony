import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio_service.dart';
import '../widgets/player_bar.dart';
import '../widgets/track_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexora'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              // Demo: escanear /tmp
              final tracks = audio.scanLibrary('/tmp');
              if (tracks.isNotEmpty && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Encontradas ${tracks.length} pistas')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nexora Music Player',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audio.initialized ? 'Motor Rust inicializado' : 'Inicializando...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: audio.initialized
                        ? () {
                            final track = audio.createLocalTrack(
                              id: 'demo-local-001',
                              title: 'Demo Track',
                              artist: 'Nexora',
                              album: 'Demo',
                              filePath: '/tmp/demo.mp3',
                              durationMs: 210000,
                            );
                            audio.loadTrack(track);
                            audio.setVolume(0.8);
                            audio.play();
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Demo: Cargar y reproducir'),
                  ),
                  const SizedBox(height: 32),
                  const TrackList(),
                ],
              ),
            ),
          ),
          const PlayerBar(),
        ],
      ),
    );
  }
}
```