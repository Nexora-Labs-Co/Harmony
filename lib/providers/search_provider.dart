import 'package:flutter/foundation.dart';

import '../bridge/bridge_generated.dart';
import '../services/youtube_service.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<Track> _localResults = [];
  List<YouTubeTrack> _youtubeResults = [];
  bool _isSearching = false;
  bool _searchYouTube = true;

  String get query => _query;
  List<Track> get localResults => _localResults;
  List<YouTubeTrack> get youtubeResults => _youtubeResults;
  bool get isSearching => _isSearching;
  bool get searchYouTube => _searchYouTube;

  void toggleYouTube(bool value) {
    _searchYouTube = value;
    notifyListeners();
  }

  Future<void> search(String query, List<Track> allTracks) async {
    _query = query;
    _isSearching = query.isNotEmpty;

    if (query.isEmpty) {
      _localResults = [];
      _youtubeResults = [];
      notifyListeners();
      return;
    }

    // Búsqueda local
    final q = query.toLowerCase();
    _localResults = allTracks
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.artist.toLowerCase().contains(q) ||
            t.album.toLowerCase().contains(q))
        .toList();

    // Búsqueda en YouTube
    if (_searchYouTube) {
      debugPrint('SearchProvider: searching YouTube for $query');
      _youtubeResults = await YouTubeService.instance.search(query);
      debugPrint('SearchProvider: found ${_youtubeResults.length} YouTube results');
    } else {
      _youtubeResults = [];
    }

    notifyListeners();
  }

  void clear() {
    _query = '';
    _localResults = [];
    _youtubeResults = [];
    _isSearching = false;
    notifyListeners();
  }
}
