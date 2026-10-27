use crate::audio::AudioEngine;
use crate::favorites::FavoritesManager;
use crate::library::scanner::LibraryScanner;
use crate::models::{LocalTrack, Track, TrackType};
use crate::playlist::{Playlist, PlaylistManager};
use crate::search::SearchEngine;
use std::path::PathBuf;

static mut AUDIO_ENGINE: Option<AudioEngine> = None;
static mut LIBRARY_SCANNER: Option<LibraryScanner> = None;
static mut FAVORITES_MANAGER: Option<FavoritesManager> = None;
static mut PLAYLIST_MANAGER: Option<PlaylistManager> = None;
static mut SEARCH_ENGINE: Option<SearchEngine> = None;

fn get_engine() -> &'static mut AudioEngine {
    unsafe {
        if AUDIO_ENGINE.is_none() {
            let engine = AudioEngine::new().expect("Failed to initialize Nexora AudioEngine");
            let _ = engine.init();
            AUDIO_ENGINE = Some(engine);
        }
        AUDIO_ENGINE.as_mut().unwrap()
    }
}

fn get_scanner() -> &'static LibraryScanner {
    unsafe {
        if LIBRARY_SCANNER.is_none() {
            LIBRARY_SCANNER = Some(LibraryScanner::new());
        }
        LIBRARY_SCANNER.as_ref().unwrap()
    }
}

fn get_favorites() -> &'static FavoritesManager {
    unsafe {
        if FAVORITES_MANAGER.is_none() {
            FAVORITES_MANAGER = Some(FavoritesManager::new());
        }
        FAVORITES_MANAGER.as_ref().unwrap()
    }
}

fn get_playlists() -> &'static PlaylistManager {
    unsafe {
        if PLAYLIST_MANAGER.is_none() {
            PLAYLIST_MANAGER = Some(PlaylistManager::new());
        }
        PLAYLIST_MANAGER.as_ref().unwrap()
    }
}

fn get_search() -> &'static SearchEngine {
    unsafe {
        if SEARCH_ENGINE.is_none() {
            SEARCH_ENGINE = Some(SearchEngine::new());
        }
        SEARCH_ENGINE.as_ref().unwrap()
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_init() -> bool {
    let engine = get_engine();
    engine.init()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_teardown() {
    let engine = get_engine();
    engine.teardown();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_create_local_track(
    id: String,
    title: String,
    artist: String,
    album: String,
    album_art: Option<String>,
    file_path: String,
    duration_ms: u64,
) -> Track {
    let local = LocalTrack::new(id, title, artist, album, album_art, PathBuf::from(&file_path), duration_ms);
    local.to_track()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_load_track(track: Track) -> bool {
    let engine = get_engine();
    engine.load_track(&track)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_play() {
    let engine = get_engine();
    engine.play();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_pause() {
    let engine = get_engine();
    engine.pause();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_stop() {
    let engine = get_engine();
    engine.stop();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_is_playing() -> bool {
    let engine = get_engine();
    engine.is_playing()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_set_volume(volume: f32) {
    let engine = get_engine();
    engine.set_volume(volume);
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_volume() -> f32 {
    let engine = get_engine();
    engine.get_volume()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_current_source() -> Option<String> {
    let engine = get_engine();
    engine.get_current_source()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_is_initialized() -> bool {
    let engine = get_engine();
    engine.is_initialized()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_scan_library(directory: String) -> Vec<Track> {
    let scanner = get_scanner();
    let path = PathBuf::from(directory);
    match scanner.scan_directory(&path) {
        Ok(locals) => locals.into_iter().map(|l| l.to_track()).collect(),
        Err(_) => vec![],
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_track_type_label(track_type: TrackType) -> String {
    match track_type {
        TrackType::Local => "Local".to_string(),
        TrackType::Remote => "Remota".to_string(),
    }
}

// Favoritos
#[flutter_rust_bridge::frb(sync)]
pub fn nexora_add_favorite(track_id: String) {
    let fav = get_favorites();
    fav.add(&track_id);
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_remove_favorite(track_id: String) {
    let fav = get_favorites();
    fav.remove(&track_id);
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_toggle_favorite(track_id: String) -> bool {
    let fav = get_favorites();
    fav.toggle(&track_id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_is_favorite(track_id: String) -> bool {
    let fav = get_favorites();
    fav.is_favorite(&track_id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_favorite_ids() -> Vec<String> {
    let fav = get_favorites();
    fav.get_all_ids()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_favorites(tracks: Vec<Track>) -> Vec<Track> {
    let fav = get_favorites();
    fav.filter_favorites(&tracks)
}

// Playlists
#[flutter_rust_bridge::frb(sync)]
pub fn nexora_create_playlist(name: String, description: String) -> Playlist {
    let pm = get_playlists();
    pm.create_playlist(name, description)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_all_playlists() -> Vec<Playlist> {
    let pm = get_playlists();
    pm.get_all_playlists()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_playlist(id: String) -> Option<Playlist> {
    let pm = get_playlists();
    pm.get_playlist(&id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_add_track_to_playlist(playlist_id: String, track_id: String) -> bool {
    let pm = get_playlists();
    pm.add_track(&playlist_id, &track_id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_remove_track_from_playlist(playlist_id: String, track_id: String) -> bool {
    let pm = get_playlists();
    pm.remove_track(&playlist_id, &track_id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_delete_playlist(playlist_id: String) -> bool {
    let pm = get_playlists();
    pm.delete_playlist(&playlist_id)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_rename_playlist(playlist_id: String, new_name: String) -> bool {
    let pm = get_playlists();
    pm.rename_playlist(&playlist_id, new_name)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_playlist_tracks(playlist_id: String, all_tracks: Vec<Track>) -> Vec<Track> {
    let pm = get_playlists();
    pm.get_tracks_for_playlist(&playlist_id, &all_tracks)
}

// Búsqueda
#[flutter_rust_bridge::frb(sync)]
pub fn nexora_search_tracks(query: String, tracks: Vec<Track>) -> Vec<Track> {
    let se = get_search();
    se.search(&query, &tracks)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_search_by_artist(artist: String, tracks: Vec<Track>) -> Vec<Track> {
    let se = get_search();
    se.search_by_artist(&artist, &tracks)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_search_by_album(album: String, tracks: Vec<Track>) -> Vec<Track> {
    let se = get_search();
    se.search_by_album(&album, &tracks)
}

