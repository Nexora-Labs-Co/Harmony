#pragma once

#include <string>
#include <memory>

namespace nexora::core::audio {

class IAudioBackend {
public:
    virtual ~IAudioBackend() = default;

    virtual bool initialize() = 0;
    virtual void shutdown() = 0;

    virtual bool load(const std::string& sourceUri) = 0;
    virtual void play() = 0;
    virtual void pause() = 0;
    virtual void stop() = 0;

    virtual bool isPlaying() const = 0;
    virtual void setVolume(float volume) = 0;
    virtual float getVolume() const = 0;
};

} // namespace nexora::core::audio
