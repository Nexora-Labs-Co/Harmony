use crate::audio::player::AudioPlayer;
use crate::models::Track;
use anyhow::Result;
use parking_lot::Mutex;
use std::path::PathBuf;
use std::sync::Arc;

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
        *self.initialized.lock() = true;
        tracing::info!("[NexoraAudioEngine] Inicializado (cpal + rodio + symphonia)");
        true
    }

    pub fn teardown(&self) {
        self.player.stop();
        *self.initialized.lock() = false;
        *self.current_uri.lock() = None;
        tracing::info!("[NexoraAudioEngine] Teardown completado");
    }

    pub fn load_track(&self, track: &Track) -> bool {
        if !*self.initialized.lock() {
            return false;
        }

        let uri = track.source_uri.clone();
        if uri.starts_with("file://") {
            let path_str = uri.trim_start_matches("file://").to_string();
            let path = PathBuf::from(path_str);
            match self.player.load_path(&path) {
                Ok(_) => {
                    *self.current_uri.lock() = Some(uri.clone());
                    tracing::info!("[NexoraAudioEngine] Cargado: {}", uri);
                    true
                }
                Err(e) => {
                    tracing::error!("[NexoraAudioEngine] Error al cargar: {}", e);
                    false
                }
            }
        } else {
            tracing::warn!("[NexoraAudioEngine] Solo se soportan URIs file:// por ahora");
            false
        }
    }

    pub fn play(&self) {
        if !*self.initialized.lock() {
            return;
        }
        self.player.play();
        tracing::debug!("[NexoraAudioEngine] Play");
    }

    pub fn pause(&self) {
        if !*self.initialized.lock() {
            return;
        }
        self.player.pause();
        tracing::debug!("[NexoraAudioEngine] Pause");
    }

    pub fn stop(&self) {
        if !*self.initialized.lock() {
            return;
        }
        self.player.stop();
        tracing::debug!("[NexoraAudioEngine] Stop");
    }

    pub fn is_playing(&self) -> bool {
        self.player.is_playing()
    }

    pub fn is_initialized(&self) -> bool {
        *self.initialized.lock()
    }

    pub fn set_volume(&self, volume: f32) {
        if !*self.initialized.lock() {
            return;
        }
        self.player.set_volume(volume);
        tracing::debug!("[NexoraAudioEngine] Volumen: {:.2}", volume.clamp(0.0, 1.0));
    }

    pub fn get_volume(&self) -> f32 {
        self.player.get_volume()
    }

    pub fn get_current_source(&self) -> Option<String> {
        self.current_uri.lock().clone()
    }
}

impl Default for AudioEngine {
    fn default() -> Self {
        Self::new().expect("Failed to create AudioEngine")
    }
}
```