use crate::models::Track;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Playlist {
    pub id: String,
    pub name: String,
    pub description: String,
    pub track_ids: Vec<String>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Clone)]
pub struct PlaylistManager {
    playlists: Arc<Mutex<HashMap<String, Playlist>>>,
}

impl PlaylistManager {
    pub fn new() -> Self {
        Self {
            playlists: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub fn create_playlist(&self, name: String, description: String) -> Playlist {
        let now = chrono::Utc::now().timestamp();
        let playlist = Playlist {
            id: Uuid::new_v4().to_string(),
            name,
            description,
            track_ids: Vec::new(),
            created_at: now,
            updated_at: now,
        };
        self.playlists.lock().unwrap().insert(playlist.id.clone(), playlist.clone());
        playlist
    }

    pub fn get_playlist(&self, id: &str) -> Option<Playlist> {
        self.playlists.lock().unwrap().get(id).cloned()
    }

    pub fn get_all_playlists(&self) -> Vec<Playlist> {
        self.playlists.lock().unwrap().values().cloned().collect()
    }

    pub fn add_track(&self, playlist_id: &str, track_id: &str) -> bool {
        let mut playlists = self.playlists.lock().unwrap();
        if let Some(playlist) = playlists.get_mut(playlist_id) {
            if !playlist.track_ids.contains(&track_id.to_string()) {
                playlist.track_ids.push(track_id.to_string());
                playlist.updated_at = chrono::Utc::now().timestamp();
            }
            true
        } else {
            false
        }
    }

    pub fn remove_track(&self, playlist_id: &str, track_id: &str) -> bool {
        let mut playlists = self.playlists.lock().unwrap();
        if let Some(playlist) = playlists.get_mut(playlist_id) {
            playlist.track_ids.retain(|id| id != track_id);
            playlist.updated_at = chrono::Utc::now().timestamp();
            true
        } else {
            false
        }
    }

    pub fn delete_playlist(&self, playlist_id: &str) -> bool {
        self.playlists.lock().unwrap().remove(playlist_id).is_some()
    }

    pub fn rename_playlist(&self, playlist_id: &str, new_name: String) -> bool {
        let mut playlists = self.playlists.lock().unwrap();
        if let Some(playlist) = playlists.get_mut(playlist_id) {
            playlist.name = new_name;
            playlist.updated_at = chrono::Utc::now().timestamp();
            true
        } else {
            false
        }
    }

    pub fn get_tracks_for_playlist(&self, playlist_id: &str, all_tracks: &[Track]) -> Vec<Track> {
        if let Some(playlist) = self.get_playlist(playlist_id) {
            playlist
                .track_ids
                .iter()
                .filter_map(|id| all_tracks.iter().find(|t| &t.id == id).cloned())
                .collect()
        } else {
            Vec::new()
        }
    }
}

impl Default for PlaylistManager {
    fn default() -> Self {
        Self::new()
    }
}
