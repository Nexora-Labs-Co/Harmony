#include "LocalTrack.h"

namespace nexora::core::models {

LocalTrack::LocalTrack(std::string id,
                       std::string title,
                       std::string artist,
                       std::string album,
                       std::filesystem::path filePath,
                       std::chrono::milliseconds duration)
    : m_id(std::move(id))
    , m_title(std::move(title))
    , m_artist(std::move(artist))
    , m_album(std::move(album))
    , m_filePath(std::move(filePath))
    , m_duration(duration)
{
}

std::string LocalTrack::getId() const { return m_id; }
std::string LocalTrack::getTitle() const { return m_title; }
std::string LocalTrack::getArtist() const { return m_artist; }
std::string LocalTrack::getAlbum() const { return m_album; }
std::string LocalTrack::getSourceUri() const { return "file://" + m_filePath.string(); }
std::chrono::milliseconds LocalTrack::getDuration() const { return m_duration; }
Track::Type LocalTrack::getType() const { return Track::Type::Local; }

const std::filesystem::path& LocalTrack::getFilePath() const { return m_filePath; }

} // namespace nexora::core::models
