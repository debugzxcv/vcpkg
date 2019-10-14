if(_VCPKG_CLANG AND NOT EXISTS ${_VCPKG_CLANG})
    unset(_VCPKG_CLANG CACHE)
    message(WARNING "unset _VCPKG_CLANG")
endif()

find_program(_VCPKG_CLANG clang)
mark_as_advanced(_VCPKG_CLANG)

function(_vcpkg_llvm_dir OUT_DIR)
    if(_VCPKG_CLANG)
        execute_process(COMMAND ${_VCPKG_CLANG} --version OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE OUT_VAR)
        string(REGEX MATCH "InstalledDir:[ \t]*([^\n]+)" OUT_VAR ${OUT_VAR})
        # message("OUT_VAR: ${OUT_VAR}")
        # message("CMAKE_MATCH_1: ${CMAKE_MATCH_1}")
        set(${OUT_DIR} ${CMAKE_MATCH_1} PARENT_SCOPE)
    endif()
endfunction()

function(_vcpkg_llvm_arch OUT_ARCH)
    if(_VCPKG_CLANG)
        execute_process(
            COMMAND ${_VCPKG_CLANG} -print-effective-triple
            OUTPUT_VARIABLE OUT_VAR
        )
        if(OUT_VAR)
            if(OUT_VAR MATCHES "^x86_64-")
                set(${OUT_ARCH} x64 PARENT_SCOPE)
            else()
                set(${OUT_ARCH} x86 PARENT_SCOPE)
            endif()
        endif()
    endif()
endfunction()

function(_vcpkg_llvm_clang OUT_DIR OUT_ARCH)
    _vcpkg_llvm_dir(${OUT_DIR})
    _vcpkg_llvm_arch(${OUT_ARCH})
    set(${OUT_DIR} ${${OUT_DIR}} PARENT_SCOPE)
    set(${OUT_ARCH} ${${OUT_ARCH}} PARENT_SCOPE)
endfunction()