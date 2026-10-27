#pragma once

#include <string>
#include <chrono>

namespace nexora::core::models {

class Track {
public:
    virtual ~Track() = default;

    virtual std::string getId() const = 0;
    virtual std::string getTitle() const = 0;
    virtual std::string getArtist() const = 0;
    virtual std::string getAlbum() const = 0;
    virtual std::string getSourceUri() const = 0;
    virtual std::chrono::milliseconds getDuration() const = 0;

    enum class Type { Local, Remote };
    virtual Type getType() const = 0;
};

} // namespace nexora::core::models
