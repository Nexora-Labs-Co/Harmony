import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../providers/profile_provider.dart';
import 'dart:io';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({
    super.key,
    this.leftSidebarVisible = true,
    this.rightPanelVisible = true,
    this.onToggleLeft,
    this.onToggleRight,
    this.onToggleNotifications,
    this.onToggleAccount,
    this.onOpenSearch,
    this.onOpenSettings,
  });

  final bool leftSidebarVisible;
  final bool rightPanelVisible;
  final VoidCallback? onToggleLeft;
  final VoidCallback? onToggleRight;
  final VoidCallback? onToggleNotifications;
  final VoidCallback? onToggleAccount;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenSettings;

  @override
  State<DesktopTopBar> createState() => _DesktopTopBarState();
}

class _DesktopTopBarState extends State<DesktopTopBar> {
  @override
  Widget build(BuildContext context) {
    return NexoraActionBar(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 18,
            padding: const EdgeInsets.all(8),
            icon: FaIcon(
              widget.leftSidebarVisible
                  ? FontAwesomeIcons.chevronLeft
                  : FontAwesomeIcons.chevronRight,
              color: const Color(0xFFEBF5EE),
            ),
            onPressed: widget.onToggleLeft,
          ),
          IconButton(
            iconSize: 18,
            padding: const EdgeInsets.all(8),
            icon: const FaIcon(FontAwesomeIcons.gear, color: Color(0xFFEBF5EE)),
            tooltip: 'Configuracion',
            onPressed: widget.onOpenSettings,
          ),
          IconButton(
            iconSize: 18,
            padding: const EdgeInsets.all(8),
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                color: Color(0xFFEBF5EE)),
            tooltip: 'Buscar',
            onPressed: widget.onOpenSearch,
          ),
        ],
      ),
      center: null,
      right: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 18,
            padding: const EdgeInsets.all(8),
            icon: const FaIcon(FontAwesomeIcons.bell, color: Color(0xFFEBF5EE)),
            tooltip: 'Notificaciones',
            onPressed: widget.onToggleNotifications,
          ),
          IconButton(
            iconSize: 18,
            padding: const EdgeInsets.all(8),
            icon: FaIcon(
              widget.rightPanelVisible
                  ? FontAwesomeIcons.chevronRight
                  : FontAwesomeIcons.chevronLeft,
              color: const Color(0xFFEBF5EE),
            ),
            onPressed: widget.onToggleRight,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onToggleAccount,
            child: Builder(
              builder: (context) {
                final profile = context.watch<ProfileProvider>();
                return CircleAvatar(
                  radius: 14,
                  backgroundColor: NexoraColors.surfaceHover,
                  backgroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : null,
                  child: profile.avatarPath == null
                      ? Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : 'H',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: NexoraColors.foreground))
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}