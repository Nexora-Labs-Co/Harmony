import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _sidebarVisible = true;
  bool _rightPanelVisible = true;
  double _leftWidth = 280;
  double _rightWidth = 320;
  static const double _minPanelWidth = 120;
  static const double _maxPanelWidth = 420;
  static const double _autoHideThreshold = 90;

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
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarVisible) ...[
                  SizedBox(
                    width: _leftWidth,
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
                  _PanelResizeHandle(
                    onDragUpdate: (delta) {
                      setState(() {
                        final next = _leftWidth + delta;
                        if (next < _autoHideThreshold) {
                          _sidebarVisible = false;
                          _leftWidth = 280;
                        } else {
                          _leftWidth = next.clamp(_minPanelWidth, _maxPanelWidth);
                        }
                      });
                    },
                  ),
                ],
                Expanded(
                  flex: 3,
                  child: _selectedPlaylistId != null
                      ? AlbumDetailContent(playlistId: _selectedPlaylistId!)
                      : DesktopMainContent(selectedIndex: _selectedIndex),
                ),
                if (_rightPanelVisible) ...[
                  _PanelResizeHandle(
                    onDragUpdate: (delta) {
                      setState(() {
                        final next = _rightWidth - delta;
                        if (next < _autoHideThreshold) {
                          _rightPanelVisible = false;
                          _rightWidth = 320;
                        } else {
                          _rightWidth = next.clamp(_minPanelWidth, _maxPanelWidth);
                        }
                      });
                    },
                  ),
                  SizedBox(
                    width: _rightWidth,
                    child: const DesktopRightPanel(),
                  ),
                ],
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


class _PanelResizeHandle extends StatelessWidget {
  const _PanelResizeHandle({required this.onDragUpdate});

  final ValueChanged<double> onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        child: Container(
          width: 6,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 2,
              color: NexoraColors.border,
            ),
          ),
        ),
      ),
    );
  }
}
