import 'package:flutter/material.dart';

import 'package:xora/xora.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final List<String> _playlists = ['Local'];

  Future<void> _addPlaylist() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    setState(() => _playlists.add(name));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                icon: XoraIcon(XoraIcons.magnifyingGlass),
                onPressed: () {},
              ),
              IconButton(
                icon: XoraIcon(XoraIcons.plus),
                onPressed: _addPlaylist,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              return XoraCard(
                child: Container(
                  decoration: BoxDecoration(
                    color: XoraColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.queue_music, size: 48)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
