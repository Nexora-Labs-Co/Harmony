use crate::audio::AudioEngine;
use crate::library::scanner::LibraryScanner;
use base64::Engine as _;
use lofty::file::{AudioFile, TaggedFileExt};
use lofty::picture::PictureType;
use lofty::read_from_path;
use lofty::tag::Accessor;
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

#[no_mangle]
pub extern "C" fn nexora_ffi_duration_ms(path: *const c_char) -> u64 {
    if path.is_null() {
        return 0;
    }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let tagged = match read_from_path(path_str) {
        Ok(t) => t,
        Err(_) => return 0,
    };
    tagged.properties().duration().as_millis() as u64
}

fn read_tag(path_str: &str) -> Option<lofty::tag::Tag> {
    let tagged = read_from_path(path_str).ok()?;
    tagged.primary_tag().cloned().or_else(|| tagged.first_tag().cloned())
}

fn cstring_from(s: String) -> *mut c_char {
    CString::new(s).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut())
}

#[no_mangle]
pub extern "C" fn nexora_ffi_artist(path: *const c_char) -> *mut c_char {
    if path.is_null() { return std::ptr::null_mut(); }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() { Ok(s) => s, Err(_) => return std::ptr::null_mut() };
    let tag = match read_tag(path_str) { Some(t) => t, None => return std::ptr::null_mut() };
    let val = tag.artist().map(|s| s.to_string()).unwrap_or_default();
    if val.is_empty() { cstring_from("Artista desconocido".to_string()) } else { cstring_from(val) }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_album(path: *const c_char) -> *mut c_char {
    if path.is_null() { return std::ptr::null_mut(); }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() { Ok(s) => s, Err(_) => return std::ptr::null_mut() };
    let tag = match read_tag(path_str) { Some(t) => t, None => return std::ptr::null_mut() };
    let val = tag.album().map(|s| s.to_string()).unwrap_or_default();
    if val.is_empty() { cstring_from("Album desconocido".to_string()) } else { cstring_from(val) }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_title(path: *const c_char) -> *mut c_char {
    if path.is_null() { return std::ptr::null_mut(); }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() { Ok(s) => s, Err(_) => return std::ptr::null_mut() };
    let tag = match read_tag(path_str) { Some(t) => t, None => return std::ptr::null_mut() };
    let val = tag.title().map(|s| s.to_string()).unwrap_or_default();
    if val.is_empty() {
        // fallback to file stem
        std::path::Path::new(path_str).file_stem().and_then(|s| s.to_str()).map(|s| cstring_from(s.to_string())).unwrap_or(std::ptr::null_mut())
    } else {
        cstring_from(val)
    }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_artwork_base64(path: *const c_char) -> *mut c_char {
    if path.is_null() { return std::ptr::null_mut(); }
    let cstr = unsafe { CStr::from_ptr(path) };
    let path_str = match cstr.to_str() { Ok(s) => s, Err(_) => return std::ptr::null_mut() };
    let tagged = match read_from_path(path_str) { Ok(t) => t, Err(_) => return std::ptr::null_mut() };
    let tag = tagged.primary_tag().or_else(|| tagged.first_tag());
    let pic = tag.and_then(|t| {
        t.pictures().iter().find(|p| p.pic_type() == PictureType::CoverFront)
            .or_else(|| t.pictures().first())
    });
    match pic {
        Some(p) => {
            let b64 = base64::engine::general_purpose::STANDARD.encode(p.data());
            cstring_from(b64)
        }
        None => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn nexora_ffi_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe { let _ = CString::from_raw(ptr); }
    }
}
