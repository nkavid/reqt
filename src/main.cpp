#include <nlohmann/json-schema.hpp>
#include <iostream>
#include <iomanip>
#include <cstdlib>

static nlohmann::json person_schema = R"(
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "A person",
    "properties": {
      "name": {
          "description": "Name",
          "type": "string"
      },
      "age": {
          "description": "Age of the person",
          "type": "number",
          "minimum": 2,
          "maximum": 200
      },
      "address":{
        "type": "object",
        "properties":{
          "street":{
            "type": "string",
            "default": "Abbey Road"
          }
        }
      }
    },
    "required": [
                 "name",
                 "age"
                 ],
    "type": "object"
}

)"_json;

static nlohmann::json bad_person = {{"age", 42}};
static nlohmann::json good_person = {{"name", "Albert"}, {"age", 42}, {"address", {{"street", "Main Street"}}}};
static nlohmann::json good_defaulted_person = {{"name", "Knut"}, {"age", 69}, {"address", {}}};

int main()
{
  nlohmann::json_schema::json_validator validator{};

  validator.set_root_schema(person_schema);

	class custom_error_handler : public nlohmann::json_schema::basic_error_handler
	{
		void error(const nlohmann::json::json_pointer &ptr, const nlohmann::json &instance, const std::string &message) override
		{
			nlohmann::json_schema::basic_error_handler::error(ptr, instance, message);
			std::cerr << "ERROR: '" << ptr << "' - '" << instance << "': " << message << "\n";
		}
	};

	for (auto &person : {bad_person, good_person}) {
		std::cout << "About to validate this person:\n"
		          << std::setw(2) << person << std::endl;

		custom_error_handler err;
		validator.validate(person, err); // validate the document

		if (err)
			std::cerr << "Validation failed\n";
		else
			std::cout << "Validation succeeded\n";
	}

  return EXIT_SUCCESS;
}
