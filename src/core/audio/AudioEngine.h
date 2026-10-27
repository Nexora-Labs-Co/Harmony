#pragma once

#include <memory>
#include <string>
#include "../models/Track.h"

namespace nexora::core::audio {

class IAudioBackend;

class AudioEngine {
public:
    explicit AudioEngine(std::unique_ptr<IAudioBackend> backend);
    ~AudioEngine();

    bool init();
    void teardown();

    bool loadTrack(const models::Track& track);
    void play();
    void pause();
    void stop();

    bool isPlaying() const;
    bool isInitialized() const;

    void setVolume(float volume);
    float getVolume() const;

    std::string getCurrentSource() const;

private:
    std::unique_ptr<IAudioBackend> m_backend;
    bool m_initialized = false;
    std::string m_currentSource;
};

} // namespace nexora::core::audio
