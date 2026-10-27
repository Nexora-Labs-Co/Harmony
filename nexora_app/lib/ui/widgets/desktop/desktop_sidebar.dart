import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:provider/provider.dart';
import '../../../providers/playlist_provider.dart';
import '../../../providers/library_provider.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Nexora',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.folder_open, size: 20),
                  tooltip: 'Escanear carpeta',
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null && context.mounted) {
                      final library = context.read<LibraryProvider>();
                      await library.scanLibrary(selectedDirectory);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${library.allTracks.length} pistas encontradas')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  label: 'Inicio',
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.music_note,
                  label: 'Biblioteca',
                  index: 1,
                  subtitle: '${libraryProvider.allTracks.length} canciones',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.favorite_border,
                  label: 'Favoritos',
                  index: 2,
                  subtitle: '${libraryProvider.favorites.length} canciones',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.search,
                  label: 'Buscar',
                  index: 3,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Playlists',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add, size: 16),
                  onPressed: () => _showCreatePlaylistDialog(context, playlistProvider),
                  tooltip: 'Crear playlist',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: playlistProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistProvider.playlists[index];
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.queue_music, size: 16),
                  title: Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${playlist.trackIds.length} pistas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    String? subtitle,
  }) {
    final isSelected = selectedIndex == index;
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, size: 18),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        onItemSelected(index);
      },
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
}
