import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/track_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexora'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.folderOpen),
            tooltip: 'Escanear carpeta',
            onPressed: () async {
              String? selectedDirectory = await FilePicker.getDirectoryPath();
              if (selectedDirectory != null && context.mounted) {
                await library.scanLibrary(selectedDirectory);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${library.allTracks.length} pistas encontradas')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            tooltip: 'Acerca de',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Nexora',
                applicationVersion: '26.10.27 (Beta)',
                applicationLegalese: '© 2026 Nexora Labs\nPolyForm Noncommercial License 1.0.0',
              );
            },
          ),
        ],
      ),
      body: library.isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Escaneando biblioteca...'),
                ],
              ),
            )
          : library.allTracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.music,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Biblioteca vacía',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escanea una carpeta para añadir música',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () async {
                          String? selectedDirectory = await FilePicker.getDirectoryPath();
                          if (selectedDirectory != null && context.mounted) {
                            await library.scanLibrary(selectedDirectory);
                          }
                        },
                        icon: FaIcon(FontAwesomeIcons.folderOpen),
                        label: const Text('Seleccionar carpeta'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${library.allTracks.length} pistas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              player.setQueue(library.allTracks);
                            },
                            icon: FaIcon(FontAwesomeIcons.play),
                            label: const Text('Reproducir todo'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: library.allTracks.length,
                        itemBuilder: (context, index) {
                          final track = library.allTracks[index];
                          return TrackTile(
                            track: track,
                            onTap: () {
                              player.setQueue(library.allTracks, startIndex: index);
                            },
                            onFavoriteToggle: () {
                              library.toggleFavorite(track.id);
                            },
                            isFavorite: library.isFavorite(track.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
