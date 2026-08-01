"""foo"""

# cspell: ignore brobeson codemodel
# pylint: disable=missing-function-docstring


import argparse
import dataclasses
import enum
import glob
import json
import os
import sys
from typing import List, Optional


class TargetType(enum.StrEnum):
    """
    Encapsulates the possible target types.
    """

    EXECUTABLE = "EXECUTABLE"
    STATIC_LIBRARY = "STATIC_LIBRARY"
    SHARED_LIBRARY = "SHARED_LIBRARY"
    MODULE_LIBRARY = "MODULE_LIBRARY"
    OBJECT_LIBRARY = "OBJECT_LIBRARY"
    INTERFACE_LIBRARY = "INTERFACE_LIBRARY"
    UTILITY = "UTILITY"


@dataclasses.dataclass
class Target:
    """
    Represents a target read from a ``target-<name>...json`` file.

    Attributes:
        id(str): The ``id`` field of the JSON object.
        name(str): The ``name`` field of the JSON object.
    """

    id: str
    name: str
    target_type: TargetType
    dependencies: List[str]


def main() -> None:
    arguments = parse_command_line()
    cmake_binary_dir = os.getcwd()
    api_reply_dir = os.path.join(cmake_binary_dir, ".cmake", "api", "v1", "reply")
    targets = filter_targets(read_target_replies(api_reply_dir))
    write_component_diagrams(cmake_binary_dir, targets)
    sys.exit(0)


def parse_command_line() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="foo")
    parser.add_argument("top-level-target")
    return parser.parse_args()


def read_target_replies(api_reply_dir: str) -> List[Target]:
    os.chdir(api_reply_dir)
    target_files = glob.glob("target-*.json")
    if not target_files:
        sys.exit(f"Failed to find target reply files in {api_reply_dir}")
    return [read_target_reply(f) for f in target_files]


def read_target_reply(filepath: str) -> Target:
    with open(filepath, encoding="utf-8", mode="r") as f:
        reply = json.load(f)
        return Target(
            reply["id"],
            reply["name"],
            reply["type"],
            (
                [d["id"] for d in reply["compileDependencies"]]
                if "compileDependencies" in reply
                else []
            ),
        )


def filter_targets(targets: List[Target]) -> List[Target]:
    targets_to_exclude = [
        "Python3::InterpreterMultiConfig",
        "diagrams.component",
        "Python3::Interpreter",
        "Git::Git",
    ]
    return list(filter(lambda t: t.name not in targets_to_exclude, targets))


def write_component_diagrams(cmake_binary_dir: str, targets: List[Target]) -> None:
    diagram_dir = os.path.join(cmake_binary_dir, "component_diagrams")
    os.makedirs(diagram_dir, exist_ok=True)
    write_component_diagram(os.path.join(diagram_dir, "targets.puml"), targets)


def write_component_diagram(filepath: str, targets: List[Target]) -> None:
    print("Writing", filepath)
    with open(filepath, encoding="utf-8", mode="w") as f:
        f.write("@startuml\n\n")
        for t in targets:
            write_target_to_diagram(f, t)
        # Keep these two loops separate. write_target_to_diagram()
        # accounts for grouping targets by CMake namespace. All packages
        # need to be in the puml file before the components are otherwise
        # referenced.
        for t in targets:
            write_dependencies_to_diagram(f, t, targets)
        f.write("\n@enduml\n")


def write_target_to_diagram(file, target: Target) -> None:
    parts = []
    if "." in target.name:
        parts = target.name.split(".")
        print(parts)
    elif "::" in target.name:
        parts = target.name.split("::")
        print(parts)
    if parts:
        print("writing parts")
        file.writelines(
            [
                f'package "{parts[0]}" {{\n',
                f"[{parts[1]}] <<{target.target_type.lower().replace("_", " ")}>> as {target.name}\n"
                "}\n",
            ]
        )
    else:
        file.write(
            f"[{target.name}] <<{target.target_type.lower().replace("_", " ")}>>\n"
        )


def write_dependencies_to_diagram(file, target: Target, targets: List[Target]) -> None:
    for d in target.dependencies:
        dependency = find_target(targets, d)
        if dependency:
            file.write(f"[{target.name}] --> [{dependency.name}]\n")


def find_target(targets: List[Target], target_id: str) -> Optional[Target]:
    for t in targets:
        if t.id == target_id:
            return t
    return None


main()
