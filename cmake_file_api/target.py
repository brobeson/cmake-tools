"""Provides encapsulation of a target file from the API."""

from dataclasses import dataclass
from enum import StrEnum
from typing import List, Optional


# todo Move this to a common file. It's probably in other parts of the API.
@dataclass
class CodeModelVersion:
    major: int
    minor: int


class TargetType(StrEnum):
    EXECUTABLE = "EXECUTABLE"
    STATIC_LIBRARY = "STATIC_LIBRARY"
    SHARED_LIBRARY = "SHARED_LIBRARY"
    MODULE_LIBRARY = "MODULE_LIBRARY"
    OBJECT_LIBRARY = "OBJECT_LIBRARY"
    INTERFACE_LIBRARY = "INTERFACE_LIBRARY"
    UTILITY = "UTILITY"


@dataclass
class Folder:
    name: str


@dataclass
class Paths:
    source: str
    build: str


@dataclass
class Artifact:
    path: str


@dataclass
class Prefix:
    path: str


@dataclass
class Destination:
    path: str
    backtrace: Optional[int]


@dataclass
class Install:
    prefix: Prefix
    destinations: List[Destination]


class LauncherType(StrEnum):
    EMULATOR = "emulator"
    TEST = "test"


@dataclass
class Launcher:
    command: str
    arguments: Optional[List[str]]
    launcher_type: LauncherType


class Role(StrEnum):
    FLAGS = "flags"
    LIBRARIES = "libraries"
    LIBRARY_PATH = "libraryPath"
    FRAMEWORK_PATH = "frameworkPath"


@dataclass
class SysRoot:
    path: str


@dataclass
class CommandFragment:
    fragment: str
    role: Role
    backtrace: Optional[int]
    lto: Optional[bool]
    sysroot: Optional[SysRoot]


@dataclass
class Link:
    language: str  # todo Should this be a StrEnum?
    command_fragments: Optional[List[CommandFragment]]


@dataclass
class Target:
    id: str
    name: str
    abstract: Optional[bool]
    symbolic: Optional[bool]
    backtrace: Optional[int]
    target_type: TargetType
    imported: Optional[bool]
    local: Optional[bool]
    folder: Optional[Folder]
    code_model_version: CodeModelVersion
    paths: Paths
    name_on_disk: str
    artifacts: Optional[List[Artifact]]
    is_generator_provided: Optional[bool]
    install: Optional[Install]
    launchers: Optional[List[Launcher]]
    link: Optional[Link]
