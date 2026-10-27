import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/library_provider.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({super.key});

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
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 280),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 18),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, size: 18),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar canciones, artistas, álbumes...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.search, size: 16),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, size: 14),
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (value) {
                        searchProvider.search(value, libraryProvider.allTracks);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, size: 18),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, size: 18),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Text('N'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
