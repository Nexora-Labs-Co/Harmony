import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

import '../../../providers/library_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/search_provider.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({
    super.key,
    this.leftSidebarVisible = true,
    this.rightPanelVisible = true,
    this.onToggleLeft,
    this.onToggleRight,
    this.onToggleNotifications,
    this.onToggleAccount,
  });

  final bool leftSidebarVisible;
  final bool rightPanelVisible;
  final VoidCallback? onToggleLeft;
  final VoidCallback? onToggleRight;
  final VoidCallback? onToggleNotifications;
  final VoidCallback? onToggleAccount;

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
            icon: FaIcon(
              widget.leftSidebarVisible ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.chevronRight,
              color: const Color(0xFFEBF5EE),
              size: 22,
            ),
            onPressed: widget.onToggleLeft,
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.gear, color: Color(0xFFEBF5EE), size: 22),
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
              child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 22, color: NexoraColors.muted),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: FaIcon(FontAwesomeIcons.xmark, size: 22, color: NexoraColors.muted),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.bell, color: Color(0xFFEBF5EE), size: 22),
            tooltip: 'Notificaciones',
            onPressed: widget.onToggleNotifications,
          ),
          IconButton(
            icon: FaIcon(
              widget.rightPanelVisible ? FontAwesomeIcons.chevronRight : FontAwesomeIcons.chevronLeft,
              color: const Color(0xFFEBF5EE),
              size: 22,
            ),
            onPressed: widget.onToggleRight,
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: Center(
              child: GestureDetector(
                onTap: widget.onToggleAccount,
                child: Builder(
                  builder: (context) {
                    final profile = context.watch<ProfileProvider>();
                    return CircleAvatar(
                      radius: 14,
                      backgroundColor: NexoraColors.surfaceHover,
                      backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                      child: profile.avatarPath == null
                          ? Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'H', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NexoraColors.foreground))
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
