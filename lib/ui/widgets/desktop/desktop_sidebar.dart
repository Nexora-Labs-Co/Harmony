import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';

import '../../../providers/playlist_provider.dart';

class DesktopSidebar extends StatefulWidget {
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
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  String? _pinnedAlbumId;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: NexoraColors.surfaceAlt,
        border: Border(
          right: BorderSide(color: NexoraColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              children: [
                _gridTile(
                  context,
                  assetPath: 'assets/icons/Logo-Inicio.png',
                  selected: widget.selectedIndex == 0,
                  onTap: () => widget.onItemSelected(0),
                ),
                _gridTile(
                  context,
                  assetPath: 'assets/icons/Logo-Favoritos.png',
                  selected: widget.selectedIndex == 1,
                  onTap: () => widget.onItemSelected(1),
                ),
                _gridTile(
                  context,
                  assetPath: 'assets/icons/Logo-Harmony-512.png',
                  selected: widget.selectedIndex == 2,
                  onTap: () => widget.onItemSelected(2),
                ),
                _gridTile(
                  context,
                  assetPath: 'assets/icons/Logo-Harmony-512.png',
                  selected: widget.selectedIndex == 3,
                  onTap: () => _handlePinnedAlbum(context, playlistProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: NexoraColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Albumes',
                  style: TextStyle(
                    color: NexoraColors.foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 16, color: NexoraColors.foreground),
                  tooltip: 'Crear album',
                  onPressed: playlistProvider.playlists.length >= 500
                      ? null
                      : () => _showCreatePlaylistDialog(context, playlistProvider),
                ),
              ],
            ),
          ),
          Expanded(
            child: playlistProvider.playlists.isEmpty
                ? const Center(
                    child: Text(
                      'Sin albumes',
                      style: TextStyle(color: NexoraColors.muted, fontSize: 12),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: playlistProvider.playlists.length.clamp(0, 500),
                    itemBuilder: (context, index) {
                      final playlist = playlistProvider.playlists[index];
                      return InkWell(
                        onTap: () => widget.onPlaylistSelected(playlist.id),
                        borderRadius: BorderRadius.circular(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: NexoraColors.surfaceHover,
                              border: Border.all(color: NexoraColors.border),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.album,
                                size: 40,
                                color: NexoraColors.mutedStrong,
                              ),
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

  Widget _gridTile(
    BuildContext context, {
    IconData? icon,
    String? assetPath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? NexoraColors.foreground : NexoraColors.border,
            ),
          ),
          child: assetPath != null
              ? SizedBox.expand(
                  child: assetPath.toLowerCase().endsWith('.svg')
                      ? SvgPicture.asset(
                          assetPath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        )
                      : Image.asset(
                          assetPath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: NexoraColors.muted),
                          ),
                        ),
                )
              : (icon != null
                  ? Icon(icon, size: 32, color: NexoraColors.foreground)
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }

  void _handlePinnedAlbum(BuildContext context, PlaylistProvider provider) {
    if (provider.playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay albumes para fijar.')),
      );
      return;
    }
    if (_pinnedAlbumId != null) {
      final pinned = provider.playlists.firstWhere(
        (p) => p.id == _pinnedAlbumId,
        orElse: () => provider.playlists.first,
      );
      widget.onPlaylistSelected(pinned.id);
      return;
    }
    // Pick first album as pinned by default.
    setState(() => _pinnedAlbumId = provider.playlists.first.id);
    widget.onPlaylistSelected(provider.playlists.first.id);
  }

  void _showCreatePlaylistDialog(BuildContext context, PlaylistProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear album'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Mi album'),
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
