use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TrackType {
    Local,
    Remote,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Track {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album: String,
    pub album_art: Option<String>,
    pub source_uri: String,
    pub duration_ms: u64,
    pub track_type: TrackType,
    path: Option<String>,
}

impl Track {
    pub fn new(
        id: String,
        title: String,
        artist: String,
        album: String,
        album_art: Option<String>,
        source_uri: String,
        duration_ms: u64,
        track_type: TrackType,
        path: Option<String>,
    ) -> Self {
        Self {
            id,
            title,
            artist,
            album,
            album_art,
            source_uri,
            duration_ms,
            track_type,
            path,
        }
    }

    pub fn get_path(&self) -> Option<&str> {
        self.path.as_deref()
    }
}
