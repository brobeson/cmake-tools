Getting Started
---------------

You have two options for incorporating cmake-tools into your project:

1. As a :ref:`Git submodule <submodule>`
2. As an :ref:`installed package <package>`

.. _submodule:

Using cmake-tools as a Submodule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can clone cmake-tools as a submodule of your project.

.. code-block:: bash

  git submodule add https://github.com/brobeson/cmake-tools.git

1. In your CMakeLists.txt file, set `CMAKE_MODULE_PATH <https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html>`_.
2. Use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_ and `include() <https://cmake.org/cmake/help/latest/command/include.html>`_ to load cmake-tools modules.

Here is an example that sets the module search path, then loads the Lizard and CMakeToolsDefaultCompileOptions modules:

.. code-block:: cmake

  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-tools")
  find_package(Lizard)
  include(CMakeToolsDefaultCompileOptions)

.. _package:

Using cmake-tools as a System Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Alternatively, you can install the tools as a system package.

Downloading and Installing the Package
......................................

1. `Download <https://github.com/brobeson/cmake-tools/releases>`_ the package for your system and the version you want.
2. **Optional** Download the accompanying SHA256 checksum and validate your package file.
3. Install the package using the method appropriate for your system and the package file you downloaded.

.. warning::

  Only the packages listed in the download location are officially supported.
  If you need a different package, you can try to build it yourself.
  See :ref:`building-package` below for details.

Finding the Package
...................

After you install the package, use it in your project's CMakeLists.txt file.

1. Use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_ to load cmake-tools.
2. Use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_ and `include() <https://cmake.org/cmake/help/latest/command/include.html>`_ to load cmake-tools modules.

The package configuration file appends the correct path to the `CMAKE_MODULE_PATH <https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html>`_, so you don't need to.
Here is an example that finds cmake-tools, then loads the Lizard and CMakeToolsDefaultCompileOptions modules:

.. code-block:: cmake

  find_package(cmake-tools)
  find_package(Lizard)
  include(CMakeToolsDefaultCompileOptions)

Result Variables
================

The cmake-tools config module defines these variables.

.. variable:: cmake-tools_FOUND

  This is set to ``TRUE`` if the package is found, and ``FALSE`` if it's not.
  Realistically, this should always be ``TRUE`` as long as CMake can find and run the config module.

.. variable:: cmake-tools_VERSION

  This is set to the version of cmake-tools found by CMake.

.. _building-package:

Building a Package
..................

If you need to build a package from scratch, follow these instructions.

1. Clone the repository.
2. Create a build directory.
   If you want your build directory to be in the source tree, I recommend using *build/* because it's already ignored by Git.
3. Change directory to your build directory.
4. Run CMake.
5. Run CPack. You must specify the CPack generator on the command line.

Here is an example that creates a Debian package on Linux:

.. code-block:: bash

  git clone https://github.com/brobeson/cmake-tools.git
  mkdir cmake-tools/build
  cd cmake-tools/build
  cmake ..
  cpack -G DEB
