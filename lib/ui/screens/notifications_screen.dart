import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const NotificationsScreen({super.key, this.onClose});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'What\'s New',
                style: TextStyle(color: NexoraColors.foreground, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.onClose != null)
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.xmark, size: 22, color: NexoraColors.muted),
                  onPressed: widget.onClose,
                ),
            ],
          ),
        ),
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
                  size: 22,
                  color: NexoraColors.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  _filter == 0 ? 'No hay novedades musicales' : 'No hay novedades de podcasts',
                  style: const TextStyle(color: NexoraColors.foreground, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuando tus artistas favoritos lancen algo nuevo,\naparecerá aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: NexoraColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, int index) {
    final selected = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? NexoraColors.surfaceHover : NexoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? NexoraColors.foreground : NexoraColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? NexoraColors.foreground : NexoraColors.mutedStrong,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
