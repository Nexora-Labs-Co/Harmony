use std::path::PathBuf;

pub fn get_data_dir() -> Option<PathBuf> {
    dirs::data_dir().map(|d| d.join("Nexora"))
}

pub fn get_config_dir() -> Option<PathBuf> {
    dirs::config_dir().map(|d| d.join("Nexora"))
}

pub fn get_cache_dir() -> Option<PathBuf> {
    dirs::cache_dir().map(|d| d.join("Nexora"))
}
