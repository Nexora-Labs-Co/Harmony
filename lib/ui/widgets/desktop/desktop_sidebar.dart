import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/playlist_provider.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<String> onPlaylistSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onPlaylistSelected,
  });

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _navItem(context, Icons.home, 'Inicio', 0),
                _navItem(context, Icons.favorite_border, 'Favoritos', 1),
                _navItem(context, Icons.settings_outlined, 'Configuracion', 2),
              ],
            ),
          ),
          const Divider(height: 32),
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
                  icon: const Icon(Icons.add, size: 16),
                  tooltip: 'Crear playlist',
                  onPressed: () => _showCreatePlaylistDialog(context, playlistProvider),
                ),
              ],
            ),
          ),
          Expanded(
            child: playlistProvider.playlists.isEmpty
                ? Center(
                    child: Text(
                      'Sin playlists',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: playlistProvider.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlistProvider.playlists[index];
                      return Card(
                        child: InkWell(
                          onTap: () => onPlaylistSelected(playlist.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.queue_music, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  playlist.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${playlist.trackIds.length} pistas',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      leading: Icon(icon, size: 20),
      title: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => onItemSelected(index),
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
              decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Mi playlist'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripcion (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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