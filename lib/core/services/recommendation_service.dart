import '../models/track.dart';

class RecommendationService {
  RecommendationService._();
  static final instance = RecommendationService._();

  List<Track> _library = [];
  List<Track> _recommended = [];

  List<Track> get recommended => List.unmodifiable(_recommended);

  void setLibrary(List<Track> tracks) => _library = List<Track>.from(tracks);

  void updateForTrack(Track? track) {
    _recommended = _library.take(8).toList();
  }
}
