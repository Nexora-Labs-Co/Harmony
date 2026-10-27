import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/track_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
    final playerProvider = context.watch<PlayerProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar canciones, artistas, álbumes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          searchProvider.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                searchProvider.search(value, libraryProvider.allTracks);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: searchProvider.query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Buscar música',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Busca por título, artista o álbum',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : searchProvider.results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: 80,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin resultados',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No se encontraron canciones para "${searchProvider.query}"',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  '${searchProvider.results.length} resultado(s)',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    playerProvider.setQueue(searchProvider.results);
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Reproducir todo'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: searchProvider.results.length,
                              itemBuilder: (context, index) {
                                final track = searchProvider.results[index];
                                return TrackTile(
                                  track: track,
                                  onTap: () {
                                    playerProvider.setQueue(searchProvider.results, startIndex: index);
                                  },
                                  onFavoriteToggle: () {
                                    libraryProvider.toggleFavorite(track.id);
                                  },
                                  isFavorite: libraryProvider.isFavorite(track.id),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
