#pragma once

#include <filesystem>

namespace reqt
{
class JSONParser
{
  public:
    explicit JSONParser(const std::filesystem::path& filepath);
};
} // namespace reqt
