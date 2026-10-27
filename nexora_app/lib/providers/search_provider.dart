import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<Track> _results = [];
  bool _isSearching = false;

  String get query => _query;
  List<Track> get results => _results;
  bool get isSearching => _isSearching;

  void search(String query, List<Track> allTracks) {
    _query = query;
    _isSearching = query.isNotEmpty;
    
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    try {
      _results = nexoraSearchTracks(query: query, tracks: allTracks);
    } catch (e) {
      _results = [];
    }
    
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = [];
    _isSearching = false;
    notifyListeners();
  }
}
