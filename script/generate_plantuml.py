import argparse
import pathlib
import json
from typing import Any, Dict


def parse_arguments() -> tuple[pathlib.Path, pathlib.Path, pathlib.Path]:
    parser = argparse.ArgumentParser(
        description="--Generate diagram\n" "--Expected files:\n",
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument(
        "--output-diagram",
        dest="output_diagram",
        help="Name of output diagram file",
    )

    parser.add_argument(
        "--hlr",
        dest="hlr",
        help="Input high level requirements",
    )

    parser.add_argument(
        "--llr",
        dest="llr",
        help="Input low level requirements",
    )

    args = parser.parse_args()

    if args.output_diagram is None:
        msg = "Missing output diagram name"
        raise ValueError(msg)

    if args.hlr is None:
        msg = "Missing HLR"
        raise ValueError(msg)

    if args.llr is None:
        msg = "Missing LLR"
        raise ValueError(msg)

    return (str(args.output_diagram), pathlib.Path(args.hlr), args.llr)


def get_json_data(filepath: pathlib.Path) -> Dict[str, Any]:
    data = None
    with open(filepath) as json_file:
        data = json.load(json_file)
    return dict(data)


def create_plantuml_file(
    output_diagram: pathlib.Path,
    hlr: Dict[str, Any],
    llr: Dict[str, Any],
) -> None:
    with open(output_diagram, "w") as output_diagram_file:
        output_diagram_file.write("@startuml\n")
        output_diagram_file.write("left to right direction\n\n")

        for section in hlr["contents"]:
            for requirement in section["requirements"]:
                identification = requirement["identification"]
                output_diagram_file.write(
                    f'object "{identification}" as {identification.replace("-", "")} {{\n'
                )
                output_diagram_file.write(f'"{requirement["description"]}"\n')
                output_diagram_file.write("}\n")
            output_diagram_file.write("\n")

        for section in llr["contents"]:
            for requirement in section["requirements"]:
                identification = requirement["identification"]
                output_diagram_file.write(
                    f'object "{identification}" as {identification.replace("-", "")} {{\n'
                )
                output_diagram_file.write(f'"{requirement["description"]}"\n')
                output_diagram_file.write("}\n")
            output_diagram_file.write("\n")

        for section in llr["contents"]:
            for requirement in section["requirements"]:
                identification = requirement["identification"]
                parent = requirement["trace"]["parent"]
                output_diagram_file.write(
                    f'{parent.replace("-", "")} --> {identification.replace("-", "")}\n'
                )

            output_diagram_file.write("\n")

        output_diagram_file.write("@enduml")


def main() -> None:
    output_diagram, hlr, llr = parse_arguments()

    hlr_data = get_json_data(hlr)
    llr_data = get_json_data(llr)

    create_plantuml_file(output_diagram, hlr_data, llr_data)


if __name__ == "__main__":
    main()
