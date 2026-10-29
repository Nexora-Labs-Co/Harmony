import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/player_bar.dart';
import 'library_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';
import 'notifications_screen.dart';
import 'playlists_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    SearchScreen(),
    PlaylistsScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _screens[_currentIndex],
          ),
          if (player.currentTrack != null)
            const PlayerBar(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house),
            selectedIcon: FaIcon(FontAwesomeIcons.house),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            selectedIcon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.compactDisc),
            selectedIcon: FaIcon(FontAwesomeIcons.compactDisc),
            label: 'Albumes',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.user),
            selectedIcon: FaIcon(FontAwesomeIcons.user),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
