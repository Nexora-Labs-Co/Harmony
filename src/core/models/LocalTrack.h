#pragma once

#include "Track.h"
#include <filesystem>

namespace nexora::core::models {

class LocalTrack : public Track {
public:
    LocalTrack(std::string id,
               std::string title,
               std::string artist,
               std::string album,
               std::filesystem::path filePath,
               std::chrono::milliseconds duration = std::chrono::milliseconds(0));

    ~LocalTrack() override = default;

    std::string getId() const override;
    std::string getTitle() const override;
    std::string getArtist() const override;
    std::string getAlbum() const override;
    std::string getSourceUri() const override;
    std::chrono::milliseconds getDuration() const override;
    Track::Type getType() const override;

    const std::filesystem::path& getFilePath() const;

private:
    std::string m_id;
    std::string m_title;
    std::string m_artist;
    std::string m_album;
    std::filesystem::path m_filePath;
    std::chrono::milliseconds m_duration;
};

} // namespace nexora::core::models
