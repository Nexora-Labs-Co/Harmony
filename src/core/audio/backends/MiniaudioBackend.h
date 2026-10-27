#pragma once

#include "../IAudioBackend.h"
#include <string>

#ifdef NEXORA_USE_MINIAUDIO
#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"
#endif

namespace nexora::core::audio {

class MiniaudioBackend : public IAudioBackend {
public:
    MiniaudioBackend();
    ~MiniaudioBackend() override;

    bool initialize() override;
    void shutdown() override;

    bool load(const std::string& sourceUri) override;
    void play() override;
    void pause() override;
    void stop() override;

    bool isPlaying() const override;
    void setVolume(float volume) override;
    float getVolume() const override;

private:
    bool m_initialized = false;
    bool m_playing = false;
    bool m_loaded = false;
    float m_volume = 1.0f;
    std::string m_currentUri;

#ifdef NEXORA_USE_MINIAUDIO
    ma_engine m_engine;
#endif
};

} // namespace nexora::core::audio
