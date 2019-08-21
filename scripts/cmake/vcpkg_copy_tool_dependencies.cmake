## # vcpkg_copy_tool_dependencies
##
## Copy all DLL dependencies of built tools into the tool folder.
##
## ## Usage
## ```cmake
## vcpkg_copy_tool_dependencies(<${CURRENT_PACKAGES_DIR}/tools/${PORT}>)
## ```
## ## Parameters
## The path to the directory containing the tools.
##
## ## Notes
## This command should always be called by portfiles after they have finished rearranging the binary output, if they have any tools.
##
## ## Examples
##
## * [glib](https://github.com/Microsoft/vcpkg/blob/master/ports/glib/portfile.cmake)
## * [fltk](https://github.com/Microsoft/vcpkg/blob/master/ports/fltk/portfile.cmake)
function(vcpkg_copy_tool_dependencies TOOL_DIR)
    find_program(PS_EXE powershell PATHS ${DOWNLOADS}/tool)
    if (PS_EXE-NOTFOUND)
        if(VCPKG_PLATFORM_TOOLSET STREQUAL "external")
            include(vcpkg_llvm_clang)
            _vcpkg_llvm_dir(_VCPKG_CLANG_DIR)
        endif()
        if(NOT _VCPKG_CLANG_DIR)
        message(FATAL_ERROR "Could not find powershell in vcpkg tools, please open an issue to report this.")
        endif()
    endif()
    macro(search_for_dependencies PATH_TO_SEARCH)
        file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
        foreach(TOOL ${TOOLS})
            if(NOT _VCPKG_CLANG_DIR)
            vcpkg_execute_required_process(
                COMMAND ${PS_EXE} -noprofile -executionpolicy Bypass -nologo
                    -file ${SCRIPTS}/buildsystems/msbuild/applocal.ps1
                    -targetBinary ${TOOL}
                    -installedDir ${PATH_TO_SEARCH}
                WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
                LOGNAME copy-tool-dependencies
            )
            else()
            vcpkg_execute_required_process(
                COMMAND ${CMAKE_COMMAND}
                    -D APPLOCAL_targetBinary=${TOOL}
                    -D APPLOCAL_installedDir=${PATH_TO_SEARCH}
                    -D APPLOCAL_clangInstalledDir=${_VCPKG_CLANG_DIR}
                    -P ${SCRIPTS}/buildsystems/applocal.cmake
                WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
                LOGNAME copy-tool-dependencies
            )
            endif()
        endforeach()
    endmacro()
    search_for_dependencies(${CURRENT_PACKAGES_DIR}/bin)
    search_for_dependencies(${CURRENT_INSTALLED_DIR}/bin)
endfunction()
