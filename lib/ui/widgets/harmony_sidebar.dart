import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';

import '../../../providers/playlist_provider.dart';

/// Harmony-specific sidebar content.
///
/// Domain logic (navigation grid, pinned album handling, album grid, album
/// creation) lives here. The surrounding chrome (width, background, border,
/// scroll) is provided by the shared [NexoraSidebar] from `nexora_ui_kit`.
class HarmonySidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<String> onPlaylistSelected;
  final VoidCallback? onFavorites;

  const HarmonySidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onPlaylistSelected,
    this.onFavorites,
  });

  @override
  State<HarmonySidebar> createState() => _HarmonySidebarState();
}

class _HarmonySidebarState extends State<HarmonySidebar> {
  String? _selectedAlbumId;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();

    return Column(
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
                onTap: () => widget.onFavorites?.call(),
              ),
              _gridTile(
                context,
                assetPath: 'assets/icons/Logo-Cari.png',
                selected: widget.selectedIndex == 2,
                onTap: () => widget.onItemSelected(2),
              ),
              _gridTile(
                context,
                assetPath: 'assets/icons/Logo-Local.png',
                selected: widget.selectedIndex == 3,
                onTap: () => widget.onItemSelected(3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: NexoraColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Álbumes',
                style: TextStyle(
                  color: NexoraColors.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.plus,
                    size: 22, color: NexoraColors.foreground),
                tooltip: 'Crear album',
                onPressed: playlistProvider.playlists.length >= 500
                    ? null
                    : () =>
                        _showCreatePlaylistDialog(context, playlistProvider),
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
                    final selected = _selectedAlbumId == playlist.id;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedAlbumId = playlist.id);
                        widget.onPlaylistSelected(playlist.id);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        transform:
                            Matrix4.translationValues(0, selected ? -3 : 0, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: selected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: NexoraColors.surfaceHover,
                              border: Border.all(color: NexoraColors.border),
                            ),
                            child: (playlist.coverImagePath != null &&
                                    playlist.coverImagePath!.isNotEmpty)
                                ? Image.file(
                                    File(playlist.coverImagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: FaIcon(
                                          FontAwesomeIcons.compactDisc,
                                          size: 22,
                                          color: NexoraColors.mutedStrong),
                                    ),
                                  )
                                : const Center(
                                    child: FaIcon(FontAwesomeIcons.compactDisc,
                                        size: 22,
                                        color: NexoraColors.mutedStrong),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _gridTile(
    BuildContext context, {
    FaIconData? icon,
    String? assetPath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, selected ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: NexoraColors.surface,
              border: Border.all(color: NexoraColors.border),
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
                              child: FaIcon(FontAwesomeIcons.image,
                                  color: NexoraColors.muted),
                            ),
                          ),
                  )
                : (icon != null
                    ? FaIcon(icon, size: 22, color: NexoraColors.foreground)
                    : const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(
      BuildContext context, PlaylistProvider provider) {
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
              decoration: const InputDecoration(
                  labelText: 'Nombre', hintText: 'Mi album'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Descripcion (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.createPlaylist(
                    nameController.text, descController.text);
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
