# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindSoundTouch
-----------

Find the SoundTouch library.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``SoundTouch::SoundTouch``
  The SoundTouch library, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``SoundTouch_FOUND``
  True if System has the SoundTouch library.
``SoundTouch_VERSION``
  This is set to ``$major.$minor.$revision`` (e.g. ``2.1.2``).

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``SoundTouch_INCLUDE_DIR``
  The directory containing ``SoundTouchDLL.h``.
``SoundTouch_LIBRARY``
  The path to the SoundTouch library.

#]=======================================================================]

find_path(SoundTouch_INCLUDE_DIR
  NAMES SoundTouchDLL.h
  PATH_SUFFIXES include
)

set(_dllname SoundTouchDLL)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_dllname SoundTouchDLL_x64)
endif()

find_library(SoundTouch_LIBRARY
  NAMES ${_dllname}
  PATH_SUFFIXES lib
)
unset(_dllname)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SoundTouch
  FOUND_VAR SoundTouch_FOUND
  REQUIRED_VARS
    SoundTouch_LIBRARY
    SoundTouch_INCLUDE_DIR
  # VERSION_VAR SoundTouch_VERSION
)

if(SoundTouch_FOUND AND NOT TARGET SoundTouch::SoundTouch)
  add_library(SoundTouch::SoundTouch UNKNOWN IMPORTED)
  set_target_properties(SoundTouch::SoundTouch PROPERTIES
    IMPORTED_LOCATION "${SoundTouch_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${SoundTouch_INCLUDE_DIR}"
  )
endif()

mark_as_advanced(SoundTouch_INCLUDE_DIR SoundTouch_LIBRARY)