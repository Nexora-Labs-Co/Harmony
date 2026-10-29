import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../widgets/desktop/album_detail_content.dart';
import '../widgets/desktop/desktop_sidebar.dart';
import '../widgets/desktop/desktop_topbar.dart';
import '../screens/notifications_screen.dart';
import '../screens/account_screen.dart';
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
  bool _sidebarVisible = true;
  bool _rightPanelVisible = true;
  bool _showNotifications = false;
  bool _showAccount = false;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
      body: Column(
        children: [
          const NexoraWindowHeader(subtitle: 'HARMONY'),
          DesktopTopBar(
            leftSidebarVisible: _sidebarVisible,
            rightPanelVisible: _rightPanelVisible,
            onToggleLeft: () => setState(() => _sidebarVisible = !_sidebarVisible),
            onToggleRight: () => setState(() => _rightPanelVisible = !_rightPanelVisible),
            onToggleNotifications: () => setState(() => _showNotifications = !_showNotifications),
            onToggleAccount: () => setState(() => _showAccount = !_showAccount),
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarVisible)
                  SizedBox(
                    width: 280,
                    child: DesktopSidebar(
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
                  ),
                Expanded(
                  flex: 3,
                  child: _showNotifications
                      ? NotificationsScreen(onClose: () => setState(() => _showNotifications = false))
                      : (_showAccount
                          ? AccountScreen(onClose: () => setState(() => _showAccount = false))
                          : (_selectedPlaylistId != null
                              ? AlbumDetailContent(playlistId: _selectedPlaylistId!)
                              : DesktopMainContent(selectedIndex: _selectedIndex))),
                ),
                if (_rightPanelVisible)
                  SizedBox(
                    width: 320,
                    child: DesktopRightPanel(
                      cariActive: _selectedIndex == 2,
                      onCariFinished: () {
                        setState(() => _selectedIndex = 0);
                        final library = context.read<LibraryProvider>();
                        final player = context.read<PlayerProvider>();
                        if (library.allTracks.isNotEmpty) {
                          player.setQueue(library.allTracks, startIndex: 0);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (player.currentTrack != null)
            DesktopBottomBar(
              onToggleRightPanel: () => setState(() => _rightPanelVisible = !_rightPanelVisible),
              onToggleFullscreen: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
          NexoraFooterBar(
            left: const Text(
              'v26.10.27+1',
              style: TextStyle(color: NexoraColors.muted, fontSize: 11.5),
            ),
            right: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github, size: 16),
                  color: NexoraColors.mutedStrong,
                  onPressed: () async {
                    final uri = Uri.parse('https://github.com/Nexora-Labs-Co');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xTwitter, size: 16),
                  color: NexoraColors.mutedStrong,
                  onPressed: () async {
                    final uri = Uri.parse('https://x.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}

