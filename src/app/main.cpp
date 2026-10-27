#include <iostream>
#include <memory>
#include <filesystem>
#include <chrono>

#include "NexoraApplication.h"
#include "core/audio/AudioEngine.h"
#include "core/audio/backends/MiniaudioBackend.h"
#include "core/models/LocalTrack.h"

int main() {
    std::cout << "=================================" << std::endl;
    std::cout << "  Nexora Music Player - v0.1.0  " << std::endl;
    std::cout << "  Arquitectura: Core/UI modular " << std::endl;
    std::cout << "=================================" << std::endl;

    nexora::app::NexoraApplication app;
    
    if (!app.initialize()) {
        std::cerr << "[Error] No se pudo inicializar Nexora" << std::endl;
        return 1;
    }

    // Demo con LocalTrack
    {
        auto backend = std::make_unique<nexora::core::audio::MiniaudioBackend>();
        nexora::core::audio::AudioEngine engine(std::move(backend));
        
        if (engine.init()) {
            nexora::core::models::LocalTrack track(
                "local-001",
                "Demo Track",
                "Nexora Artist",
                "Nexora Demo Album",
                std::filesystem::current_path() / "demo.mp3",
                std::chrono::milliseconds(210000)
            );

            std::cout << "\n[Info] Pista creada:" << std::endl;
            std::cout << "  ID: " << track.getId() << std::endl;
            std::cout << "  Título: " << track.getTitle() << std::endl;
            std::cout << "  Artista: " << track.getArtist() << std::endl;
            std::cout << "  Álbum: " << track.getAlbum() << std::endl;
            std::cout << "  URI: " << track.getSourceUri() << std::endl;
            std::cout << "  Tipo: " << (track.getType() == nexora::core::models::Track::Type::Local ? "Local" : "Remota") << std::endl;

            if (engine.loadTrack(track)) {
                engine.setVolume(0.8f);
                engine.play();
                std::cout << "\n[Estado] Reproduciendo: " << (engine.isPlaying() ? "Sí" : "No") << std::endl;
                engine.pause();
                engine.stop();
            }

            engine.teardown();
        }
    }

    int result = app.run();
    app.shutdown();
    
    std::cout << "\n[Info] Nexora finalizado correctamente." << std::endl;
    return result;
}
