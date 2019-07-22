# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindLuaJIT
-----------

Find the LuaJIT library.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``LuaJIT::LuaJIT``
  The LuaJIT library, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``LuaJIT_FOUND``
  True if System has the LuaJIT library.
``LuaJIT_VERSION``
  This is set to ``$major.$minor.$revision-$patch`` (e.g. ``2.1.0-beta3``).

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``LuaJIT_INCLUDE_DIR``
  The directory containing ``luajit.h``.
``LuaJIT_LIBRARY``
  The path to the LuaJIT library.

#]=======================================================================]

find_path(LuaJIT_INCLUDE_DIR
  NAMES luajit.h
  PATH_SUFFIXES luajit
)

if(LuaJIT_INCLUDE_DIR)
  set(luajit_version_str)
  file(STRINGS "${LuaJIT_INCLUDE_DIR}/luajit.h" luajit_version_str
    REGEX "^#define[ \t]+LUAJIT_VERSION[ \t]+\"LuaJIT ([0-9]+\.[0-9]+\.[0-9]+-[a-z0-9]+)\"$"
  )
  string(REGEX REPLACE "^#define[ \t]+LUAJIT_VERSION[ \t]+\"LuaJIT ([0-9]+\.[0-9]+\.[0-9]+-[a-z0-9]+)\"$" "\\1" LuaJIT_VERSION "${luajit_version_str}")
  # message(STATUS "LUAJIT_INCLUDE_DIR: ${LUAJIT_INCLUDE_DIR}")
  # message(STATUS "luajit_version_str: ${luajit_version_str}")
  unset(luajit_version_str)
endif()

find_library(LuaJIT_LIBRARY
  NAMES luajit
  PATH_SUFFIXES lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LuaJIT
  FOUND_VAR LuaJIT_FOUND
  REQUIRED_VARS
    LuaJIT_LIBRARY
    LuaJIT_INCLUDE_DIR
  VERSION_VAR LuaJIT_VERSION
)

if(LuaJIT_FOUND AND NOT TARGET LuaJIT::LuaJIT)
  add_library(LuaJIT::LuaJIT UNKNOWN IMPORTED)
  set_target_properties(LuaJIT::LuaJIT PROPERTIES
    IMPORTED_LOCATION "${LuaJIT_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${LuaJIT_INCLUDE_DIR}"
  )
endif()

mark_as_advanced(LuaJIT_INCLUDE_DIR LuaJIT_LIBRARY)