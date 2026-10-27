use crate::models::Track;
use std::collections::HashSet;
use std::sync::{Arc, Mutex};

#[derive(Clone)]
pub struct FavoritesManager {
    favorites: Arc<Mutex<HashSet<String>>>,
}

impl FavoritesManager {
    pub fn new() -> Self {
        Self {
            favorites: Arc::new(Mutex::new(HashSet::new())),
        }
    }

    pub fn add(&self, track_id: &str) {
        self.favorites.lock().unwrap().insert(track_id.to_string());
    }

    pub fn remove(&self, track_id: &str) {
        self.favorites.lock().unwrap().remove(track_id);
    }

    pub fn is_favorite(&self, track_id: &str) -> bool {
        self.favorites.lock().unwrap().contains(track_id)
    }

    pub fn toggle(&self, track_id: &str) -> bool {
        let mut set = self.favorites.lock().unwrap();
        if set.contains(track_id) {
            set.remove(track_id);
            false
        } else {
            set.insert(track_id.to_string());
            true
        }
    }

    pub fn get_all_ids(&self) -> Vec<String> {
        self.favorites.lock().unwrap().iter().cloned().collect()
    }

    pub fn filter_favorites(&self, tracks: &[Track]) -> Vec<Track> {
        let favorites = self.favorites.lock().unwrap();
        tracks
            .iter()
            .filter(|t| favorites.contains(&t.id))
            .cloned()
            .collect()
    }
}

impl Default for FavoritesManager {
    fn default() -> Self {
        Self::new()
    }
}
