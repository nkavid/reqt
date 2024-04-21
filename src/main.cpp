#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>

#include <nlohmann/json-schema.hpp>

static void loader(const nlohmann::json_uri& uri, nlohmann::json& schema)
{
  if (uri.location() == "http://json-schema.org/draft-07/schema")
  {
    schema = nlohmann::json_schema::draft7_schema_builtin;
    return;
  }

  std::string fn = "/home/divak/repos/slask/reqt/schemas";

  fn += uri.path();
  std::cerr << fn << "\n";

  std::fstream s(fn.c_str());
  if (!s.good())
    throw std::invalid_argument("could not open " + uri.url()
                                + " for schema loading\n");

  try
  {
    s >> schema;
  }
  catch (std::exception& e)
  {
    throw e;
  }
  std::cout << schema << '\n';
}

static std::string base64_decode(const std::string& in)
{
  std::string out;

  std::vector<int> T(256, -1);
  for (int i = 0; i < 64; i++)
    T["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"[i]] = i;

  unsigned val = 0;
  int valb     = -8;
  for (uint8_t c : in)
  {
    if (c == '=')
      break;

    if (T[c] == -1)
    {
      throw std::invalid_argument(
          "base64-decode: unexpected character in encode string: '" + std::string(1, c)
          + "'");
    }
    val = (val << 6) + T[c];
    valb += 6;
    if (valb >= 0)
    {
      out.push_back(char((val >> valb) & 0xFF));
      valb -= 8;
    }
  }
  return out;
}

static void content(const std::string& contentEncoding,
                    const std::string& contentMediaType,
                    const nlohmann::json& instance)
{
  std::string content = instance;

  if (contentEncoding == "base64")
    content = base64_decode(instance);
  else if (contentEncoding != "")
    throw std::invalid_argument("unable to check for contentEncoding '"
                                + contentEncoding + "'");

  if (contentMediaType == "application/json")
    auto dummy = nlohmann::json::parse(content); // throws if conversion fails
  else if (contentMediaType != "")
    throw std::invalid_argument("unable to check for contentMediaType '"
                                + contentMediaType + "'");
}

nlohmann::json readJSON(const char* filename)
{
  std::ifstream file{filename, std::ios::ate | std::ios::binary};

  if (!file.is_open())
  {
    throw std::runtime_error(std::string{"gfx::failed to open file! "} + filename);
  }
  auto fileSize = file.tellg();
  std::vector<char> buffer(static_cast<size_t>(fileSize));
  file.seekg(0);
  file.read(buffer.data(), fileSize);
  file.close();

  return nlohmann::json::parse(buffer);
}

class CustomErrorHandler : public nlohmann::json_schema::basic_error_handler
{
    void error(const nlohmann::json::json_pointer& ptr,
               const nlohmann::json& instance,
               const std::string& message) override
    {
      nlohmann::json_schema::basic_error_handler::error(ptr, instance, message);
      std::cerr << "ERROR: '" << ptr << "' - '" << instance << "': " << message << "\n";
    }
};

int main(int argc, char** argv)
{
  auto schema = readJSON(argv[1]);

  nlohmann::json_schema::json_validator
      validator{loader, nlohmann::json_schema::default_string_format_check, content};

  validator.set_root_schema(schema);

  CustomErrorHandler errorHandler{};

  const static nlohmann::json requirement = {
      {"identification",                                              "HLR-FB-001"},
      {   "description", "The result shall be 'fizz' if integer is divisible by 3"},
      {         "hmmmm",                                                        ""},
      {         "dsgaa",                                                        ""},
      {         "hmmmm",                                                        ""}
  };

  validator.validate(requirement, errorHandler);

  return EXIT_SUCCESS;
}
