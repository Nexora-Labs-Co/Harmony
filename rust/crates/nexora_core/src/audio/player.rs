use anyhow::Result;
use rodio::{Decoder, OutputStream, OutputStreamHandle, Sink};
use std::fs::File;
use std::io::BufReader;
use std::path::Path;
use std::sync::Arc;
use std::sync::Mutex;

#[derive(Clone)]
pub struct AudioPlayer {
    _stream: Arc<Mutex<Option<OutputStream>>>,
    _stream_handle: Arc<Mutex<Option<OutputStreamHandle>>>,
    sink: Arc<Mutex<Option<Sink>>>,
    volume: Arc<Mutex<f32>>,
    playing: Arc<Mutex<bool>>,
}

impl AudioPlayer {
    pub fn new() -> Result<Self> {
        let (stream, stream_handle) = OutputStream::try_default()?;
        let sink = Sink::try_new(&stream_handle)?;
        sink.set_volume(1.0);

        Ok(Self {
            _stream: Arc::new(Mutex::new(Some(stream))),
            _stream_handle: Arc::new(Mutex::new(Some(stream_handle))),
            sink: Arc::new(Mutex::new(Some(sink))),
            volume: Arc::new(Mutex::new(1.0f32)),
            playing: Arc::new(Mutex::new(false)),
        })
    }

    pub fn load_path(&self, path: &Path) -> Result<()> {
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.stop();
        }
        let file = File::open(path)?;
        let source = Decoder::new(BufReader::new(file))?;
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.append(source);
            sink.pause();
        }
        *self.playing.lock().unwrap() = false;
        Ok(())
    }

    pub fn play(&self) {
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.play();
        }
        *self.playing.lock().unwrap() = true;
    }

    pub fn pause(&self) {
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.pause();
        }
        *self.playing.lock().unwrap() = false;
    }

    pub fn stop(&self) {
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.stop();
        }
        *self.playing.lock().unwrap() = false;
    }

    pub fn is_playing(&self) -> bool {
        *self.playing.lock().unwrap()
    }

    pub fn set_volume(&self, vol: f32) {
        let clamped = vol.clamp(0.0, 1.0);
        if let Some(sink) = self.sink.lock().unwrap().as_ref() {
            sink.set_volume(clamped);
        }
        *self.volume.lock().unwrap() = clamped;
    }

    pub fn get_volume(&self) -> f32 {
        *self.volume.lock().unwrap()
    }
}

impl Default for AudioPlayer {
    fn default() -> Self {
        Self::new().expect("Failed to initialize audio player")
    }
}
