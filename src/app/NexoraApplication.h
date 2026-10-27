#pragma once

#include <memory>
#include "core/audio/AudioEngine.h"

namespace nexora::app {

class NexoraApplication {
public:
    NexoraApplication();
    ~NexoraApplication();

    bool initialize();
    int run();
    void shutdown();

private:
    std::unique_ptr<core::audio::AudioEngine> m_audioEngine;
    bool m_initialized = false;
};

} // namespace nexora::app
