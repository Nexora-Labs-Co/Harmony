import 'package:flutter/material.dart';

import 'package:xora/xora.dart';

class CariScreen extends StatelessWidget {
  const CariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: XoraCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            XoraIcon(XoraIcons.magnifyingGlass, size: 48),
            const SizedBox(height: 16),
            Text('Cari', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Tu asistente de IA', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
