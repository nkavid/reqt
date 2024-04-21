import json
import pathlib
from jsonschema import Draft202012Validator
from referencing import Registry, Resource, jsonschema
from typing import Any, Dict, List


def get_json_data(filepath: pathlib.Path) -> Dict[str, Any]:
    data = None
    with open(filepath) as json_file:
        data = json.load(json_file)
    return dict(data)


def ensure_unique_identification(llr: Dict[str, Any]) -> None:
    identifications = []
    for section in llr["contents"]:
        for requirement in section["requirements"]:
            identification = requirement["identification"]
            if identification in identifications:
                print(f"{identification} is a duplicate requirement identification")
            identifications.append(requirement["identification"])


def check_requirement_description_contains_shall(llr: Dict[str, Any]) -> None:
    identifications: List[str] = []
    for section in llr["contents"]:
        for requirement in section["requirements"]:
            description = requirement["description"]
            if "shall" not in description:
                identification = requirement["identification"]
                print(f"{identification} does not contain the word 'shall'")


def main() -> None:

    requirement_schema = get_json_data(pathlib.Path("schemas/requirement.json"))

    schema = Resource(contents=requirement_schema, specification=jsonschema.DRAFT202012)
    registry = Registry().with_resource(uri="requirement.json", resource=schema)

    llr_schema = get_json_data(pathlib.Path("schemas/llr.json"))

    validator = Draft202012Validator(
        llr_schema,
        registry=registry,
    )

    fizzbuzz_llr = get_json_data(pathlib.Path("requirements/fizzbuzz_llr.json"))

    validator.validate(fizzbuzz_llr)

    ensure_unique_identification(fizzbuzz_llr)
    check_requirement_description_contains_shall(fizzbuzz_llr)


if __name__ == "__main__":
    main()
