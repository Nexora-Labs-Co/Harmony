import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0; // 0 music, 1 podcasts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexoraColors.background,
      appBar: AppBar(
        backgroundColor: NexoraColors.surface,
        title: const Text('What\'s New', style: TextStyle(color: NexoraColors.foreground)),
        iconTheme: const IconThemeData(color: NexoraColors.foreground),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('Music', 0),
                const SizedBox(width: 8),
                _filterChip('Podcast & Shows', 1),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    _filter == 0 ? FontAwesomeIcons.music : FontAwesomeIcons.podcast,
                    size: 48,
                    color: NexoraColors.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filter == 0 ? 'No hay novedades musicales' : 'No hay novedades de podcasts',
                    style: const TextStyle(color: NexoraColors.foreground, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cuando tus artistas favoritos lancen algo nuevo,\naparecerá aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: NexoraColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final selected = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NexoraColors.surfaceHover : NexoraColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? NexoraColors.foreground : NexoraColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? NexoraColors.foreground : NexoraColors.mutedStrong,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
