import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

import '../../../providers/library_provider.dart';
import '../../../providers/search_provider.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({
    super.key,
    this.leftSidebarVisible = true,
    this.rightPanelVisible = true,
    this.onToggleLeft,
    this.onToggleRight,
  });

  final bool leftSidebarVisible;
  final bool rightPanelVisible;
  final VoidCallback? onToggleLeft;
  final VoidCallback? onToggleRight;

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              widget.leftSidebarVisible ? Icons.chevron_left : Icons.chevron_right,
              color: const Color(0xFFEBF5EE),
              size: 24,
            ),
            onPressed: widget.onToggleLeft,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFFEBF5EE), size: 24),
            onPressed: () {},
          ),
        ],
      ),
      center: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 13, color: NexoraColors.foreground),
          decoration: InputDecoration(
            hintText: 'Buscar canciones, artistas, albumes...',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, size: 18, color: NexoraColors.muted),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: NexoraColors.muted),
                    onPressed: () {
                      _searchController.clear();
                      searchProvider.clear();
                      setState(() {});
                    },
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: NexoraColors.surfaceAlt,
            hintStyle: const TextStyle(color: NexoraColors.muted, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: NexoraColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: NexoraColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: NexoraColors.foreground),
            ),
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
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFFEBF5EE), size: 24),
            tooltip: 'Notificaciones',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              widget.rightPanelVisible ? Icons.chevron_right : Icons.chevron_left,
              color: const Color(0xFFEBF5EE),
              size: 24,
            ),
            onPressed: widget.onToggleRight,
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
