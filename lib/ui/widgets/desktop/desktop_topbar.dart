import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../providers/library_provider.dart';
import '../../../providers/search_provider.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({
    super.key,
    this.sidebarVisible = true,
    this.onToggleSidebar,
  });

  final bool sidebarVisible;
  final VoidCallback? onToggleSidebar;

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

    return NexoraActionBar(
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              widget.sidebarVisible ? Icons.chevron_left : Icons.chevron_right,
            ),
            onPressed: widget.onToggleSidebar,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      center: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar canciones, artistas, albumes...',
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
      right: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificaciones',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              widget.sidebarVisible ? Icons.chevron_right : Icons.chevron_left,
            ),
            onPressed: widget.onToggleSidebar,
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            child: Text('H', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
