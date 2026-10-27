#include "MiniaudioBackend.h"
#include <iostream>
#include <algorithm>

namespace nexora::core::audio {

MiniaudioBackend::MiniaudioBackend() {
}

MiniaudioBackend::~MiniaudioBackend() {
    shutdown();
}

bool MiniaudioBackend::initialize() {
#ifdef NEXORA_USE_MINIAUDIO
    ma_result result = ma_engine_init(NULL, &m_engine);
    if (result != MA_SUCCESS) {
        std::cerr << "[MiniaudioBackend] Error al inicializar motor de audio: " << result << std::endl;
        return false;
    }
    m_initialized = true;
    std::cout << "[MiniaudioBackend] Inicializado correctamente" << std::endl;
    return true;
#else
    std::cout << "[MiniaudioBackend] Modo sin miniaudio (dummy)" << std::endl;
    m_initialized = true;
    return true;
#endif
}

void MiniaudioBackend::shutdown() {
    if (!m_initialized) {
        return;
    }
    stop();
#ifdef NEXORA_USE_MINIAUDIO
    ma_engine_uninit(&m_engine);
#endif
    m_initialized = false;
    m_loaded = false;
    m_playing = false;
    m_currentUri.clear();
    std::cout << "[MiniaudioBackend] Apagado" << std::endl;
}

bool MiniaudioBackend::load(const std::string& sourceUri) {
    if (!m_initialized) {
        return false;
    }
    m_currentUri = sourceUri;
    m_loaded = true;
    std::cout << "[MiniaudioBackend] Cargando: " << sourceUri << std::endl;
    return true;
}

void MiniaudioBackend::play() {
    if (!m_initialized || !m_loaded) {
        return;
    }
#ifdef NEXORA_USE_MINIAUDIO
    if (!m_currentUri.empty()) {
        // Para archivo file://, extraer ruta
        std::string path = m_currentUri;
        if (path.find("file://") == 0) {
            path = path.substr(7);
        }
        ma_result result = ma_engine_play_sound(&m_engine, path.c_str(), NULL);
        if (result == MA_SUCCESS) {
            m_playing = true;
            std::cout << "[MiniaudioBackend] Reproduciendo: " << path << std::endl;
            return;
        }
    }
#endif
    m_playing = true;
    std::cout << "[MiniaudioBackend] Reproduciendo..." << std::endl;
}

void MiniaudioBackend::pause() {
    if (m_playing) {
        m_playing = false;
        std::cout << "[MiniaudioBackend] Pausado" << std::endl;
    }
}

void MiniaudioBackend::stop() {
    if (m_playing || m_loaded) {
        m_playing = false;
        std::cout << "[MiniaudioBackend] Detenido" << std::endl;
    }
}

bool MiniaudioBackend::isPlaying() const {
    return m_playing;
}

void MiniaudioBackend::setVolume(float volume) {
    m_volume = std::clamp(volume, 0.0f, 1.0f);
#ifdef NEXORA_USE_MINIAUDIO
    if (m_initialized) {
        ma_engine_set_volume(&m_engine, m_volume);
    }
#endif
    std::cout << "[MiniaudioBackend] Volumen: " << m_volume << std::endl;
}

float MiniaudioBackend::getVolume() const {
    return m_volume;
}

} // namespace nexora::core::audio
