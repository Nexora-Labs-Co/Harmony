use crate::models::Track;

#[derive(Clone)]
pub struct SearchEngine;

impl SearchEngine {
    pub fn new() -> Self {
        Self
    }

    pub fn search(&self, query: &str, tracks: &[Track]) -> Vec<Track> {
        if query.is_empty() {
            return tracks.to_vec();
        }
        let query_lower = query.to_lowercase();
        tracks
            .iter()
            .filter(|track| {
                track.title.to_lowercase().contains(&query_lower)
                    || track.artist.to_lowercase().contains(&query_lower)
                    || track.album.to_lowercase().contains(&query_lower)
            })
            .cloned()
            .collect()
    }

    pub fn search_by_artist(&self, artist: &str, tracks: &[Track]) -> Vec<Track> {
        let artist_lower = artist.to_lowercase();
        tracks
            .iter()
            .filter(|track| track.artist.to_lowercase().contains(&artist_lower))
            .cloned()
            .collect()
    }

    pub fn search_by_album(&self, album: &str, tracks: &[Track]) -> Vec<Track> {
        let album_lower = album.to_lowercase();
        tracks
            .iter()
            .filter(|track| track.album.to_lowercase().contains(&album_lower))
            .cloned()
            .collect()
    }
}

impl Default for SearchEngine {
    fn default() -> Self {
        Self::new()
    }
}
