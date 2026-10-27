use crate::audio::AudioEngine;
use crate::library::scanner::LibraryScanner;
use crate::models::{LocalTrack, Track, TrackType};
use std::path::PathBuf;

static mut AUDIO_ENGINE: Option<AudioEngine> = None;
static mut LIBRARY_SCANNER: Option<LibraryScanner> = None;

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
