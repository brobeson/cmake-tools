"""The code model file API`"""

# pylint: disable=missing-class-docstring

from dataclasses import dataclass
from typing import List
from .target import *


@dataclass
class Configuration:
    name: str
    targets: List[Target]


@dataclass
class CodeModel:
    configurations: List[Configuration]
