use crate::models::{LocalTrack, Track};
use anyhow::Result;
use lofty::file::{AudioFile, TaggedFileExt};
use lofty::read_from_path;
use lofty::tag::Accessor;
use std::collections::HashMap;
use std::fs;
use std::path::Path;
use uuid::Uuid;

#[derive(Default)]
pub struct LibraryScanner {
    supported_exts: HashMap<String, bool>,
}

impl LibraryScanner {
    pub fn new() -> Self {
        let mut supported_exts = HashMap::new();
        for ext in ["mp3", "flac", "ogg", "m4a", "wav", "opus", "aac"] {
            supported_exts.insert(ext.to_string(), true);
        }
        Self { supported_exts }
    }

    pub fn is_supported(&self, path: &Path) -> bool {
        if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
            self.supported_exts.contains_key(&ext.to_lowercase())
        } else {
            false
        }
    }

    pub fn scan_directory(&self, dir: &Path) -> Result<Vec<LocalTrack>> {
        let mut tracks = Vec::new();
        self.scan_recursive(dir, &mut tracks)?;
        Ok(tracks)
    }

    fn scan_recursive(&self, dir: &Path, tracks: &mut Vec<LocalTrack>) -> Result<()> {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_dir() {
                self.scan_recursive(&path, tracks)?;
            } else if path.is_file() && self.is_supported(&path) {
                if let Ok(track) = self.extract_metadata(&path) {
                    tracks.push(track);
                }
            }
        }
        Ok(())
    }

    fn extract_metadata(&self, path: &Path) -> Result<LocalTrack> {
        let tagged_file = read_from_path(path)?;
        let tag = tagged_file.primary_tag().or_else(|| tagged_file.first_tag());

        let title = tag
            .and_then(|t| t.title())
            .map(|s| s.to_string())
            .unwrap_or_else(|| {
                path.file_stem()
                    .and_then(|s| s.to_str())
                    .unwrap_or("Unknown")
                    .to_string()
            });

        let artist = tag
            .and_then(|t| t.artist())
            .map(|s| s.to_string())
            .unwrap_or_else(|| "Unknown Artist".to_string());

        let album = tag
            .and_then(|t| t.album())
            .map(|s| s.to_string())
            .unwrap_or_else(|| "Unknown Album".to_string());

        let duration_ms = tagged_file.properties().duration().as_millis() as u64;

        Ok(LocalTrack::new(
            Uuid::new_v4().to_string(),
            title,
            artist,
            album,
            None,
            path.to_path_buf(),
            duration_ms,
        ))
    }

    pub fn local_to_track(&self, local: &LocalTrack) -> Track {
        local.to_track()
    }
}
