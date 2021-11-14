Getting Started
---------------

You have multiple options for incorporating cmake-tools into your project:

1. With :ref:`CMake FetchContent <fetchcontent>`
2. As a :ref:`Git submodule <submodule>`

.. _fetchcontent:

With CMake FetchContent
^^^^^^^^^^^^^^^^^^^^^^^

You can use CMake's FetchContent module to load cmake-tools.

1. In your CMakeLists.txt file, use ``FetchContent`` to load cmake-tools.
2. Use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_
   and `include() <https://cmake.org/cmake/help/latest/command/include.html>`_
   to load cmake-tools modules.

.. code-block:: cmake

  include(FetchContent)
  FetchContent_Declare(
    cmake-tools
    GIT_REPOSITORY https://github.com/brobeson/cmake-tools.git
    GIT_TAG main
  )
  FetchContent_MakeAvailable(cmake-tools)
  list(APPEND CMAKE_MODULE_PATH "${cmake-tools_SOURCE_DIR}")

You may want to put these lines in your root CMakeLists.txt file, before your
top level ``project()`` command if you plan to use any cmake-tools modules in
the ``project()`` command.  One example of this is setting the project version
from the Git tag.  Here is an example:

.. code-block:: cmake

  include(CMakeToolsVersionFromGit)
  project(
    supernovas
    VERSION ${CMAKE_TOOLS_GIT_TAG}
    DESCRIPTION "A pure C++ implementation of the NOVAS library."
    HOMEPAGE_URL "https://github.com/brobeson/supernovas"
    LANGUAGES CXX
  )

.. _submodule:

Using cmake-tools as a Submodule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can clone cmake-tools as a submodule of your project.

.. code-block:: bash

  git submodule add https://github.com/brobeson/cmake-tools.git

1. In your CMakeLists.txt file, set
   `CMAKE_MODULE_PATH <https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html>`_.
2. Use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_
   and `include() <https://cmake.org/cmake/help/latest/command/include.html>`_
   to load cmake-tools modules.

.. code-block:: cmake

  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-tools")
  find_package(Lizard)
  include(CMakeToolsCompileOptions)
