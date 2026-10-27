use crate::audio::AudioEngine;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::path::PathBuf;
use std::sync::OnceLock;

static ENGINE: OnceLock<AudioEngine> = OnceLock::new();

fn engine() -> &'static AudioEngine {
    ENGINE.get_or_init(|| {
        let e = AudioEngine::new().expect("Failed to create AudioEngine");
        let _ = e.init();
        e
    })
}

#[no_mangle]
pub extern "C" fn nexora_ffi_init() -> i32 {
    let _ = engine();
    1
}

#[no_mangle]
pub extern "C" fn nexora_ffi_teardown() {
    // Engine persists for app lifetime; no-op
}

#[no_mangle]
pub extern "C" fn nexora_ffi_load_path(path: *const c_char) -> i32 {
    if path.is_null() {
        return 0;
    }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let p = PathBuf::from(path_str);
    // Use a temporary Track-like load via engine.load_track requires Track.
    // Instead call player directly through engine? Engine.load_track needs Track.
    // Reconstruct minimal: engine.load_track builds uri from track.source_uri.
    // We'll call a helper on engine instead. Add load_path to AudioEngine? 
    // AudioEngine has no load_path. Let's add one via player.
    let e = engine();
    // Access player through a new method. We'll add nexora_load_path to AudioEngine.
    if e.load_path(&p) { 1 } else { 0 }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_play() {
    engine().play();
}

#[no_mangle]
pub extern "C" fn nexora_ffi_pause() {
    engine().pause();
}

#[no_mangle]
pub extern "C" fn nexora_ffi_stop() {
    engine().stop();
}

#[no_mangle]
pub extern "C" fn nexora_ffi_is_playing() -> i32 {
    if engine().is_playing() { 1 } else { 0 }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_set_volume(vol: f32) {
    engine().set_volume(vol);
}

#[no_mangle]
pub extern "C" fn nexora_ffi_get_volume() -> f32 {
    engine().get_volume()
}

#[no_mangle]
pub extern "C" fn nexora_ffi_seek(pos_ms: u64) {
    engine().seek(pos_ms);
}
