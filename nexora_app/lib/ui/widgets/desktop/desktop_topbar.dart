import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/library_provider.dart';
import '../../../providers/search_provider.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({super.key});

  @override
  State<DesktopTopBar> createState() => _DesktopTopBarState();
}

class _DesktopTopBarState extends State<DesktopTopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final libraryProvider = context.watch<LibraryProvider>();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Harmony',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Escanear carpeta',
            onPressed: () async {
              final dir = await FilePicker.platform.getDirectoryPath();
              if (dir != null && context.mounted) {
                await libraryProvider.scanLibrary(dir);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${libraryProvider.allTracks.length} pistas encontradas')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Atrás',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Adelante',
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar canciones, artistas, álbumes...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.search, size: 18),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            searchProvider.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  searchProvider.search(value, libraryProvider.allTracks);
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificaciones',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Text('H'),
          ),
        ],
      ),
    );
  }
}
