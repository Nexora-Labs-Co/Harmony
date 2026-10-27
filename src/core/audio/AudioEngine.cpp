#include "AudioEngine.h"
#include "IAudioBackend.h"
#include <algorithm>

namespace nexora::core::audio {

AudioEngine::AudioEngine(std::unique_ptr<IAudioBackend> backend)
    : m_backend(std::move(backend))
{
}

AudioEngine::~AudioEngine() {
    teardown();
}

bool AudioEngine::init() {
    if (m_initialized) {
        return true;
    }
    if (!m_backend) {
        return false;
    }
    if (m_backend->initialize()) {
        m_initialized = true;
        return true;
    }
    return false;
}

void AudioEngine::teardown() {
    if (!m_initialized) {
        return;
    }
    stop();
    if (m_backend) {
        m_backend->shutdown();
    }
    m_initialized = false;
    m_currentSource.clear();
}

bool AudioEngine::loadTrack(const models::Track& track) {
    if (!m_initialized || !m_backend) {
        return false;
    }
    const std::string uri = track.getSourceUri();
    if (m_backend->load(uri)) {
        m_currentSource = uri;
        return true;
    }
    return false;
}

void AudioEngine::play() {
    if (!m_initialized || !m_backend) return;
    m_backend->play();
}

void AudioEngine::pause() {
    if (!m_initialized || !m_backend) return;
    m_backend->pause();
}

void AudioEngine::stop() {
    if (!m_initialized || !m_backend) return;
    m_backend->stop();
}

bool AudioEngine::isPlaying() const {
    if (!m_initialized || !m_backend) return false;
    return m_backend->isPlaying();
}

bool AudioEngine::isInitialized() const {
    return m_initialized;
}

void AudioEngine::setVolume(float volume) {
    if (!m_initialized || !m_backend) return;
    float clamped = std::clamp(volume, 0.0f, 1.0f);
    m_backend->setVolume(clamped);
}

float AudioEngine::getVolume() const {
    if (!m_initialized || !m_backend) return 0.0f;
    return m_backend->getVolume();
}

std::string AudioEngine::getCurrentSource() const {
    return m_currentSource;
}

} // namespace nexora::core::audio
