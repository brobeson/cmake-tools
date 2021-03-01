Getting Started
---------------

Using cmake-tools as a Submodule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can clone cmake-tools as a submodule of your project.

.. code-block:: bash

  git submodule add https://github.com/brobeson/cmake-tools.git

In your CMakeLists.txt file, set `CMAKE_MODULE_PATH <https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html>`_ so CMake can find the modules.
Then you can use `find_package() <https://cmake.org/cmake/help/latest/command/find_package.html>`_ and `include() <https://cmake.org/cmake/help/latest/command/include.html>`_ normally.

.. code-block:: cmake

  list(
    APPEND
    CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake-tools"
  )
  find_package(Lizard)
