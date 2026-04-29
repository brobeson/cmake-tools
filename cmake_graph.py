"""foo"""

# cspell: ignore brobeson codemodel
# pylint: disable=missing-function-docstring

import argparse
import glob
import json
import os.path
import pathlib
from pprint import pprint
import subprocess
import sys
from typing import List, Optional
from cmake_file_api import target


def main() -> int:
    current_directory = os.getcwd()
    arguments = parse_command_line()
    build_dir = arguments.p if arguments.p is not None else find_existing_build_dir()
    if build_dir is None:
        sys.exit("No build directory found")
    print(f"Found build directory {build_dir}")
    if not arguments.no_config:
        write_query_file(build_dir)
        run_cmake(build_dir)
    os.chdir(os.path.join(build_dir, ".cmake", "api", "v1", "reply"))
    index = read_reply_index()
    reply = read_code_model(get_code_model_file(index))
    targets = get_targets(reply)
    os.chdir(current_directory)
    write_targets(targets)
    return 0


def parse_command_line() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-config", action="store_true")
    parser.add_argument("-p")
    arguments = parser.parse_args()
    return arguments


def find_existing_build_dir() -> Optional[str]:
    cache_files = list(glob.glob("**/CMakeCache.txt", recursive=True))
    if not cache_files:
        return None
    if len(cache_files) > 1:
        sys.exit(
            "Found multiple build directories. Remove all but one, or specify the build directory "
            "to use."
        )
    return os.path.dirname(cache_files[0])


def write_query_file(build_dir: str) -> None:
    query_dir = os.path.join(
        build_dir, ".cmake", "api", "v1", "query", "client-brobeson-cmake-tools"
    )
    query_file = os.path.join(query_dir, "codemodel-v2")
    if os.path.exists(query_file):
        return
    os.makedirs(query_dir, exist_ok=True)
    pathlib.Path(query_file).touch()


def run_cmake(build_dir: str) -> None:
    result = subprocess.run(["cmake", build_dir], check=False)
    if result.returncode != 0:
        sys.exit(result.returncode)


def read_reply_index() -> dict:
    index_files = list(glob.glob("index-*.json"))
    if not index_files:
        sys.exit(f"Failed to find CMake's reply index file in {os.getcwd()}")
    if len(index_files) > 1:
        index_files.sort()
    with open(index_files[0], mode="r", encoding="utf-8") as index_file:
        index_content = json.load(index_file)
    return index_content


def get_code_model_file(reply_index: dict) -> str:
    return reply_index["reply"]["client-brobeson-cmake-tools"]["codemodel-v2"][
        "jsonFile"
    ]


def read_code_model(file_path: str) -> dict:
    with open(file_path, mode="r", encoding="utf-8") as reply_file:
        reply = json.load(reply_file)
    return reply


def get_targets(code_model: dict) -> list:
    targets: list = code_model["configurations"][0]["targets"]
    targets.extend(code_model["configurations"][0]["abstractTargets"])
    # targets = list(filter(lambda t: t["name"] != "Git::Git", targets))
    target_files = [t["jsonFile"] for t in targets]
    targets = [target.load_target(f) for f in target_files]
    return targets


def write_targets(targets: List[target.Target]) -> None:
    with open("targets.puml", encoding="utf-8", mode="w") as puml_file:
        puml_file.write("@startuml\n\n")
        for t in targets:
            puml_file.write(
                f"[{t.name}] <<{t.target_type.lower().replace("_", " ")}>>\n"
            )
        puml_file.write("@enduml")


if __name__ == "__main__":
    sys.exit(main())
else:
    sys.exit("This is a script, not an importable module.")
