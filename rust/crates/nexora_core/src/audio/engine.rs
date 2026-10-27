use crate::audio::player::AudioPlayer;
use crate::models::Track;
use anyhow::Result;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};

#[derive(Clone)]
pub struct AudioEngine {
    player: Arc<AudioPlayer>,
    current_uri: Arc<Mutex<Option<String>>>,
    initialized: Arc<Mutex<bool>>,
}

impl AudioEngine {
    pub fn new() -> Result<Self> {
        let player = AudioPlayer::new()?;
        Ok(Self {
            player: Arc::new(player),
            current_uri: Arc::new(Mutex::new(None)),
            initialized: Arc::new(Mutex::new(false)),
        })
    }

    pub fn init(&self) -> bool {
        *self.initialized.lock().unwrap() = true;
        tracing::info!("[NexoraAudioEngine] Initialized");
        true
    }

    pub fn teardown(&self) {
        self.player.stop();
        *self.initialized.lock().unwrap() = false;
        *self.current_uri.lock().unwrap() = None;
    }

    pub fn load_path(&self, path: &PathBuf) -> bool {
        if !*self.initialized.lock().unwrap() {
            return false;
        }
        match self.player.load_path(path) {
            Ok(_) => {
                *self.current_uri.lock().unwrap() = Some(format!("file://{}", path.display()));
                true
            }
            Err(_) => false,
        }
    }

    pub fn load_track(&self, track: &Track) -> bool {
        if !*self.initialized.lock().unwrap() {
            return false;
        }
        let uri = track.source_uri.clone();
        if uri.starts_with("file://") {
            let path_str = uri.trim_start_matches("file://").to_string();
            let path = PathBuf::from(path_str);
            match self.player.load_path(&path) {
                Ok(_) => {
                    *self.current_uri.lock().unwrap() = Some(uri);
                    true
                }
                Err(_) => false,
            }
        } else {
            false
        }
    }

    pub fn play(&self) {
        if !*self.initialized.lock().unwrap() {
            return;
        }
        self.player.play();
    }

    pub fn pause(&self) {
        if !*self.initialized.lock().unwrap() {
            return;
        }
        self.player.pause();
    }

    pub fn stop(&self) {
        if !*self.initialized.lock().unwrap() {
            return;
        }
        self.player.stop();
    }

    pub fn is_playing(&self) -> bool {
        self.player.is_playing()
    }

    pub fn is_initialized(&self) -> bool {
        *self.initialized.lock().unwrap()
    }

    pub fn set_volume(&self, volume: f32) {
        if !*self.initialized.lock().unwrap() {
            return;
        }
        self.player.set_volume(volume);
    }

    pub fn get_volume(&self) -> f32 {
        self.player.get_volume()
    }

    pub fn seek(&self, pos_ms: u64) {
        if !*self.initialized.lock().unwrap() {
            return;
        }
        self.player.seek(std::time::Duration::from_millis(pos_ms));
    }

    pub fn get_current_source(&self) -> Option<String> {
        self.current_uri.lock().unwrap().clone()
    }
}

impl Default for AudioEngine {
    fn default() -> Self {
        Self::new().expect("Failed to create AudioEngine")
    }
}

unsafe impl Send for AudioEngine {}
unsafe impl Sync for AudioEngine {}
