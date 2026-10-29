import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../widgets/desktop/album_detail_content.dart';
import '../widgets/harmony_sidebar.dart';
import '../widgets/desktop/desktop_topbar.dart';
import '../screens/notifications_screen.dart';
import '../screens/favorites_screen.dart';
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
  bool _showFavorites = false;

  // Simple navigation history for top bar back/forward.
  final List<int> _navHistory = <int>[0];
  int _navPos = 0;

  void _pushHistory(int index) {
    if (_navPos < _navHistory.length - 1) {
      _navHistory.removeRange(_navPos + 1, _navHistory.length);
    }
    if (_navHistory.isEmpty || _navHistory.last != index) {
      _navHistory.add(index);
      _navPos = _navHistory.length - 1;
    }
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedPlaylistId = null;
      _showAccount = false;
      _showNotifications = false;
      _showFavorites = index == 1;
    });
    _pushHistory(index);
  }

  void _goBack() {
    if (_navPos > 0) {
      _navPos--;
      final idx = _navHistory[_navPos];
      setState(() {
        _selectedIndex = idx;
        _selectedPlaylistId = null;
        _showAccount = false;
        _showNotifications = false;
        _showFavorites = idx == 1;
      });
    }
  }

  void _goForward() {
    if (_navPos < _navHistory.length - 1) {
      _navPos++;
      final idx = _navHistory[_navPos];
      setState(() {
        _selectedIndex = idx;
        _selectedPlaylistId = null;
        _showAccount = false;
        _showNotifications = false;
        _showFavorites = idx == 1;
      });
    }
  }

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
            onOpenSearch: () => _navigateToIndex(1),
            onBack: _goBack,
            onForward: _goForward,
            onOpenSettings: () => _navigateToIndex(2),
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarVisible)
                  NexoraSidebar(
                    width: 280,
                    padding: EdgeInsets.zero,
                    scrollable: false,
                    child: HarmonySidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: (index) {
                        _navigateToIndex(index);
                      },
                      onFavorites: () => _navigateToIndex(1),
                      onPlaylistSelected: (id) {
                        setState(() {
                          _selectedIndex = 3;
                          _selectedPlaylistId = id;
                          _showAccount = false;
                          _showNotifications = false;
                          _showFavorites = false;
                        });
                        _pushHistory(3);
                      },
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: _showNotifications
                      ? NotificationsScreen(onClose: () => setState(() => _showNotifications = false))
                      : (_showAccount
                          ? AccountScreen(onClose: () => setState(() => _showAccount = false))
                          : (_showFavorites
                              ? FavoritesScreen()
                              : (_selectedPlaylistId != null
                                  ? AlbumDetailContent(playlistId: _selectedPlaylistId!)
                                  : DesktopMainContent(selectedIndex: _selectedIndex)))), 
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

