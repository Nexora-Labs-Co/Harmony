use crate::audio::AudioEngine;
use crate::library::scanner::LibraryScanner;
use crate::models::{LocalTrack, Track, TrackType};
use once_cell::sync::Lazy;
use parking_lot::Mutex;
use std::path::PathBuf;
use std::sync::Arc;

static AUDIO_ENGINE: Lazy<Arc<Mutex<AudioEngine>>> = Lazy::new(|| {
    let engine = AudioEngine::new().expect("Failed to initialize Nexora AudioEngine");
    let _ = engine.init();
    Arc::new(Mutex::new(engine))
});

static LIBRARY_SCANNER: Lazy<LibraryScanner> = Lazy::new(LibraryScanner::new);

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_init() -> bool {
    let engine = AUDIO_ENGINE.lock();
    engine.init()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_teardown() {
    let engine = AUDIO_ENGINE.lock();
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
    let engine = AUDIO_ENGINE.lock();
    engine.load_track(&track)
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_play() {
    let engine = AUDIO_ENGINE.lock();
    engine.play();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_pause() {
    let engine = AUDIO_ENGINE.lock();
    engine.pause();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_stop() {
    let engine = AUDIO_ENGINE.lock();
    engine.stop();
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_is_playing() -> bool {
    let engine = AUDIO_ENGINE.lock();
    engine.is_playing()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_set_volume(volume: f32) {
    let engine = AUDIO_ENGINE.lock();
    engine.set_volume(volume);
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_volume() -> f32 {
    let engine = AUDIO_ENGINE.lock();
    engine.get_volume()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_get_current_source() -> Option<String> {
    let engine = AUDIO_ENGINE.lock();
    engine.get_current_source()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_is_initialized() -> bool {
    let engine = AUDIO_ENGINE.lock();
    engine.is_initialized()
}

#[flutter_rust_bridge::frb(sync)]
pub fn nexora_scan_library(directory: String) -> Vec<Track> {
    let scanner = &*LIBRARY_SCANNER;
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
```