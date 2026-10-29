import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/search_view.dart';
import '../screens/notifications_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/cari_screen.dart';
import '../widgets/desktop/desktop_bottombar.dart';
import '../widgets/desktop/desktop_main_content.dart';
import '../widgets/desktop/desktop_right_panel.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  String _appVersion = '26.10.28+2';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final yaml = await rootBundle.loadString('pubspec.yaml');
      final match = RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(yaml);
      if (match != null && mounted) {
        setState(() => _appVersion = match.group(1)!.trim());
      }
    } catch (_) {}
  }

  int _selectedIndex = 0;
  String? _selectedPlaylistId;
  bool _sidebarVisible = true;
  bool _rightPanelVisible = true;
  bool _showNotifications = false;
  bool _showAccount = false;
  bool _showFavorites = false;
  bool _showSearch = false;

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedPlaylistId = null;
      _showAccount = false;
      _showNotifications = false;
      _showFavorites = index == 1;
      _showSearch = false;
    });
  }


  Widget _buildMainContent() {
    if (_showNotifications) {
      return NotificationsScreen(onClose: () => setState(() => _showNotifications = false));
    }
    if (_showAccount) {
      return AccountScreen(onClose: () => setState(() => _showAccount = false));
    }
    if (_showSearch) {
      return const SearchView();
    }
    if (_showFavorites) {
      return const FavoritesScreen();
    }
    if (_selectedPlaylistId != null) {
      return AlbumDetailContent(playlistId: _selectedPlaylistId!);
    }
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 2:
        return const CariScreen();
      case 3:
        return const LibraryScreen();
      default:
        return DesktopMainContent(selectedIndex: _selectedIndex);
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
            onOpenSearch: () => setState(() {
              _showSearch = true;
              _selectedPlaylistId = null;
              _showAccount = false;
              _showNotifications = false;
              _showFavorites = false;
            }),
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
                          _showSearch = false;
                        });
                      },
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: _buildMainContent(),
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
            left: Text(
              'v$_appVersion',
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

