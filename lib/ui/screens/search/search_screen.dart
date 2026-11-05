import 'package:flutter/material.dart';

import 'package:xora/xora.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Buscar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        const XoraTextField(
          hint: 'Buscar canciones, artistas o álbumes',
          prefixIcon: XoraIcon(XoraIcons.magnifyingGlass),
        ),
      ],
    );
  }
}
