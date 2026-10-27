import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/playlist_provider.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear playlist',
            onPressed: () {
              _showCreatePlaylistDialog(context, playlistProvider);
            },
          ),
        ],
      ),
      body: playlistProvider.playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin playlists',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera playlist',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      _showCreatePlaylistDialog(context, playlistProvider);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear playlist'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: playlistProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistProvider.playlists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.queue_music,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(playlist.name),
                    subtitle: Text(
                      playlist.description.isEmpty 
                          ? '${playlist.trackIds.length} pistas' 
                          : '${playlist.description} • ${playlist.trackIds.length} pistas',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'play',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('Reproducir'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Renombrar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          playlistProvider.deletePlaylist(playlist.id);
                        } else if (value == 'rename') {
                          _showRenamePlaylistDialog(context, playlistProvider, playlist.id, playlist.name);
                        }
                      },
                    ),
                    onTap: () {
                      // TODO: Show playlist details
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, PlaylistProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Mi playlist',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Descripción de la playlist',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.createPlaylist(nameController.text, descController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, PlaylistProvider provider, String id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.renamePlaylist(id, nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
