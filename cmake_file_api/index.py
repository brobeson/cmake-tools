"""File API reply index"""

from dataclasses import dataclass
from typing import Optional


@dataclass
class Version:
    major: int
    minor: int
    patch: int
    is_dirty: bool
    suffix: Optional[int] = None


@dataclass
class CMake:
    version: Version
