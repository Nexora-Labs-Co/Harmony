import 'package:flutter/material.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/desktop/album_detail_content.dart';
import '../widgets/desktop/desktop_sidebar.dart';
import '../widgets/desktop/desktop_topbar.dart';
import '../widgets/desktop/desktop_bottombar.dart';
import '../widgets/desktop/desktop_main_content.dart';
import '../widgets/desktop/desktop_right_panel.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _selectedIndex = 0;
  String? _selectedPlaylistId;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    
    return Scaffold(
      body: Column(
        children: [
          const NexoraWindowHeader(subtitle: 'HARMONY'),
          const DesktopTopBar(),
          Expanded(
            child: Row(
              children: [
                DesktopSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _selectedPlaylistId = null;
                    });
                  },
                  onPlaylistSelected: (id) {
                    setState(() {
                      _selectedPlaylistId = id;
                    });
                  },
                ),
                Expanded(
                  flex: 3,
                  child: _selectedPlaylistId != null
                      ? AlbumDetailContent(playlistId: _selectedPlaylistId!)
                      : DesktopMainContent(selectedIndex: _selectedIndex),
                ),
                const DesktopRightPanel(),
              ],
            ),
          ),
          if (player.currentTrack != null)
            const DesktopBottomBar(),
        ],
      ),
    );
  }
}
