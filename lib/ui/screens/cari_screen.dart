import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class CariScreen extends StatelessWidget {
  const CariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NexoraColors.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cari',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu asistente de voz',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: FaIcon(FontAwesomeIcons.microphone, size: 64),
          ),
        ],
      ),
    );
  }
}