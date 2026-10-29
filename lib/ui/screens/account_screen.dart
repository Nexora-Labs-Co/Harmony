import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../providers/playlist_provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class AccountScreen extends StatelessWidget {
  final VoidCallback? onClose;
  const AccountScreen({super.key, this.onClose});

  Future<void> _pickAvatar(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.isNotEmpty && result.single.path != null) {
      await profile.setAvatarPath(result.single.path);
    }
  }

  Future<void> _editName(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final controller = TextEditingController(text: profile.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexoraColors.surfaceAlt,
        title: const Text('Editar nombre', style: TextStyle(color: NexoraColors.foreground)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: NexoraColors.foreground),
          decoration: const InputDecoration(
            hintText: 'Nombre de usuario',
            hintStyle: TextStyle(color: NexoraColors.muted),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              profile.setName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final playlists = context.watch<PlaylistProvider>().playlists;

    return Scaffold(
      backgroundColor: NexoraColors.background,
      appBar: AppBar(
        backgroundColor: NexoraColors.surface,
        title: const Text('Cuenta', style: TextStyle(color: NexoraColors.foreground)),
        iconTheme: const IconThemeData(color: NexoraColors.foreground),
        actions: [
          if (onClose != null)
            IconButton(
              icon: FaIcon(FontAwesomeIcons.xmark, size: 14, color: NexoraColors.foreground),
              onPressed: onClose,
            ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.gear, color: NexoraColors.foreground),
            onPressed: () {},
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.ellipsis, color: NexoraColors.foreground),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickAvatar(context),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: NexoraColors.surfaceHover,
                    backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                    child: profile.avatarPath == null
                        ? FaIcon(FontAwesomeIcons.user, size: 14, color: NexoraColors.foreground)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Profile', style: TextStyle(color: NexoraColors.muted, fontSize: 12, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _editName(context),
                        child: Text(
                          profile.name,
                          style: const TextStyle(color: NexoraColors.foreground, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${playlists.length} Public Playlists',
                        style: const TextStyle(color: NexoraColors.mutedStrong, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Top artists this month',
              style: TextStyle(color: NexoraColors.foreground, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _ArtistChip(name: 'Blessd'),
                  _ArtistChip(name: 'Kris R.'),
                  _ArtistChip(name: 'Tury'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistChip extends StatelessWidget {
  final String name;
  const _ArtistChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: NexoraColors.surfaceHover,
            child: FaIcon(FontAwesomeIcons.user, color: NexoraColors.muted),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: NexoraColors.foreground, fontSize: 11, fontWeight: FontWeight.w500)),
          const Text('Artist', style: TextStyle(color: NexoraColors.muted, fontSize: 9)),
        ],
      ),
    );
  }
}
