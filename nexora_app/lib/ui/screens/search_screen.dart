import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/search_provider.dart';
import '../../services/youtube_service.dart';
import '../widgets/cached_artwork.dart';
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
      appBar: AppBar(title: const Text('Buscar'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar canciones, artistas, albumes o YouTube...',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (value) {
                searchProvider.search(value, libraryProvider.allTracks);
              },
            ),
          ),
          Expanded(
            child: searchProvider.query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Buscar musica', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text('Busca en tu biblioteca o en YouTube',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (searchProvider.localResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text('Biblioteca local', style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...searchProvider.localResults.map((track) => TrackTile(
                              track: track,
                              onTap: () => playerProvider.setQueue(searchProvider.localResults, startIndex: searchProvider.localResults.indexOf(track)),
                              onFavoriteToggle: () => libraryProvider.toggleFavorite(track.id),
                              isFavorite: libraryProvider.isFavorite(track.id),
                            )),
                      ],
                      if (searchProvider.youtubeResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text('YouTube', style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...searchProvider.youtubeResults.map((yt) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedArtwork(
                                  albumArt: yt.thumbnailUrl,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(4),
                                  fallback: Container(
                                    width: 48,
                                    height: 48,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.play_circle),
                                  ),
                                ),
                              ),
                              title: Text(yt.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${yt.artist} • ${_fmt(yt.duration)}'),
                              trailing: const Icon(Icons.play_arrow),
                              onTap: () async {
                                await YouTubeService.instance.playTrack(yt);
                              },
                            )),
                      ],
                      if (searchProvider.localResults.isEmpty && searchProvider.youtubeResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text('Sin resultados para "${searchProvider.query}"'),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}
