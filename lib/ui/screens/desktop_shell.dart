import 'package:flutter/material.dart';
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
    );
  }
}
