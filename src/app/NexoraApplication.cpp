#include "NexoraApplication.h"
#include "core/audio/backends/MiniaudioBackend.h"
#include <iostream>

namespace nexora::app {

NexoraApplication::NexoraApplication() {
}

NexoraApplication::~NexoraApplication() {
    shutdown();
}

bool NexoraApplication::initialize() {
    if (m_initialized) {
        return true;
    }

    auto backend = std::make_unique<core::audio::MiniaudioBackend>();
    m_audioEngine = std::make_unique<core::audio::AudioEngine>(std::move(backend));

    if (!m_audioEngine->init()) {
        std::cerr << "[NexoraApplication] Error al inicializar motor de audio" << std::endl;
        return false;
    }

    m_initialized = true;
    std::cout << "[NexoraApplication] Inicializado correctamente" << std::endl;
    return true;
}

int NexoraApplication::run() {
    if (!m_initialized) {
        if (!initialize()) {
            return 1;
        }
    }

    std::cout << "\n[NexoraApplication] Ejecutándose..." << std::endl;
    std::cout << "[NexoraApplication] Usa Ctrl+C para salir" << std::endl;

    return 0;
}

void NexoraApplication::shutdown() {
    if (m_audioEngine) {
        m_audioEngine->teardown();
        m_audioEngine.reset();
    }
    m_initialized = false;
    std::cout << "[NexoraApplication] Cerrado" << std::endl;
}

} // namespace nexora::app
