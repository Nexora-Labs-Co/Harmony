use crate::models::{Track, TrackType};
use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct LocalTrack {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album: String,
    pub album_art: Option<String>,
    pub file_path: PathBuf,
    pub duration_ms: u64,
}

impl LocalTrack {
    pub fn new(
        id: impl Into<String>,
        title: impl Into<String>,
        artist: impl Into<String>,
        album: impl Into<String>,
        album_art: Option<String>,
        file_path: impl Into<PathBuf>,
        duration_ms: u64,
    ) -> Self {
        Self {
            id: id.into(),
            title: title.into(),
            artist: artist.into(),
            album: album.into(),
            album_art,
            file_path: file_path.into(),
            duration_ms,
        }
    }

    pub fn to_track(&self) -> Track {
        let source_uri = format!("file://{}", self.file_path.display());
        Track::new(
            self.id.clone(),
            self.title.clone(),
            self.artist.clone(),
            self.album.clone(),
            self.album_art.clone(),
            source_uri,
            self.duration_ms,
            TrackType::Local,
            Some(self.file_path.display().to_string()),
        )
    }
}
```