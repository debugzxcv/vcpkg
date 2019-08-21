cmake_minimum_required(VERSION 3.3)
# set(CMAKE_MESSAGE_LOG_LEVEL DEBUG)
# set(CMAKE_MESSAGE_CONTEXT_SHOW ON)
list(APPEND CMAKE_MESSAGE_CONTEXT "applocal")
message(DEBUG "targetBinary: \"${APPLOCAL_targetBinary}\"")
message(DEBUG "installedDir: \"${APPLOCAL_installedDir}\"")
message(DEBUG "clangInstalledDir: \"${APPLOCAL_clangInstalledDir}\"")

set(llvmLibs
    "c++.dll"
    "libclang.dll"
    "libiomp5md.dll"
    "liblldb.dll"
    "libomp.dll"
    "LLVM-C.dll"
    "LTO.dll"
    "Remarks.dll"
)

if(EXISTS "${APPLOCAL_clangInstalledDir}")
    file(TO_NATIVE_PATH "${APPLOCAL_clangInstalledDir}/llvm-readobj" dumpbin)
    if(NOT EXISTS "${dumpbin}")
        file(TO_NATIVE_PATH "${APPLOCAL_clangInstalledDir}/llvm-objdump" dumpbin)
        function(resolve_llvm_objdump OUT_LIBS TARGET_BINARY)
            list(APPEND CMAKE_MESSAGE_CONTEXT "resolve_llvm_objdump")
            execute_process(
                COMMAND "${dumpbin}" -p "${TARGET_BINARY}"
                OUTPUT_STRIP_TRAILING_WHITESPACE
                OUTPUT_VARIABLE out
            )
            string(REGEX MATCHALL "DLL Name:[ \t]*[^.]*\.dll" out ${out})
            list(TRANSFORM out REPLACE "DLL Name:[ \t]*" "")
            # list(REMOVE_DUPLICATES out)
            set(${OUT_LIBS} ${out} PARENT_SCOPE)
            message(DEBUG "bin: ${TARGET_BINARY}; libs: ${out}")
        endfunction()
    endif()
    function(resolve_llvm_readobj OUT_LIBS TARGET_BINARY)
        list(APPEND CMAKE_MESSAGE_CONTEXT "resolve_llvm_readobj")
        execute_process(
            COMMAND "${dumpbin}" --coff-imports "${TARGET_BINARY}"
            OUTPUT_STRIP_TRAILING_WHITESPACE
            OUTPUT_VARIABLE out
        )
        string(REGEX MATCHALL "(Import|DelayImport) {[ \t\r\n]*Name:[ \t]*[^.]*\.dll" out ${out})
        list(TRANSFORM out REPLACE "(Import|DelayImport) {[ \t\r\n]*Name:[ \t]*" "")
        # list(REMOVE_DUPLICATES out)
        set(${OUT_LIBS} ${out} PARENT_SCOPE)
        message(DEBUG "bin: ${TARGET_BINARY}; libs: ${out}")
    endfunction()
endif()


function(deploy_binary TARGET_BINARY_DIR SOURCE_DIR TARGET_BINARY_NAME)
    list(APPEND CMAKE_MESSAGE_CONTEXT "deploy_binary")
    if(EXISTS "${TARGET_BINARY_DIR}/${TARGET_BINARY_NAME}")
        file(TIMESTAMP "${SOURCE_DIR}/${TARGET_BINARY_NAME}" sourceModTime "%s")
        file(TIMESTAMP "${TARGET_BINARY_DIR}/${TARGET_BINARY_NAME}" destModTime "%s")
        message(DEBUG "sourceModTime: ${sourceModTime}, destModTime: ${destModTime}")
        if (destModTime LESS sourceModTime)
            # message("${TARGET_BINARY_NAME}: Updating ${SOURCE_DIR}/${TARGET_BINARY_NAME}")
            file(COPY "${SOURCE_DIR}/${TARGET_BINARY_NAME}" DESTINATION "${TARGET_BINARY_DIR}")
        else()
            # message("${TARGET_BINARY_NAME}: ${TARGET_BINARY_DIR}/${TARGET_BINARY_NAME} already present")
        endif()

    else()
        # message("${TARGET_BINARY_NAME}: Copying ${SOURCE_DIR}/${TARGET_BINARY_NAME}")
        file(COPY "${SOURCE_DIR}/${TARGET_BINARY_NAME}" DESTINATION "${TARGET_BINARY_DIR}")
    endif()
endfunction()

get_filename_component(baseTargetBinaryDir "${APPLOCAL_targetBinary}" DIRECTORY)
get_filename_component(installedDirRoot "${APPLOCAL_installedDir}" DIRECTORY)
set(scachedLibs)
set(stacks 0)

function(resolve TARGET_BINARY)
    list(APPEND CMAKE_MESSAGE_CONTEXT "resolve")
    if(NOT EXISTS "${TARGET_BINARY}")
        message(FATAL_ERROR "${TARGET_BINARY} NOT EXISTS")
    endif()
    get_filename_component(targetBinaryDir "${TARGET_BINARY}" DIRECTORY)
    if(COMMAND resolve_llvm_objdump)
        resolve_llvm_objdump(libs "${TARGET_BINARY}")
    else()
        resolve_llvm_readobj(libs "${TARGET_BINARY}")
    endif()

    if(stacks EQUAL 0)
        message("Copying dependencies to ${baseTargetBinaryDir} ...")
        message("${TARGET_BINARY}")
    endif()
    
    list(LENGTH libs libs_len)
    set(libs_index 0)
    foreach(lib ${libs})
        math(EXPR _libs_index "${libs_index}+1")

        set(msgstr)
        if(stacks GREATER 0)
            # if(_libs_index EQUAL libs_len)
            #     math(EXPR _repeat "${stacks}-1")
            #     string(REPEAT "│ " ${_repeat} spaces)
            #     string(APPEND spaces "  ")
            # else()
                string(REPEAT "│ " ${stacks} spaces)
            # endif()
            string(APPEND msgstr ${spaces})
        endif()

        if(libs_len GREATER 1 AND _libs_index LESS libs_len)
            string(APPEND msgstr "├─")
        else()
            string(APPEND msgstr "└─")
        endif()
        message("${msgstr}${lib}")

        math(EXPR libs_index "${libs_index}+1")
        if(${lib} IN_LIST scachedLibs)
            # message("${lib}: previously searched - Skip")
            continue()
        endif()

        list(APPEND scachedLibs "${lib}")
        set(scachedLibs ${scachedLibs} PARENT_SCOPE)

        set(sourceDir "${APPLOCAL_installedDir}")
        if(APPLOCAL_clangInstalledDir AND ${lib} IN_LIST llvmLibs)
            set(sourceDir "${APPLOCAL_clangInstalledDir}")
        endif()

        if(EXISTS "${sourceDir}/${lib}")
            deploy_binary("${baseTargetBinaryDir}" "${sourceDir}" "${lib}")
            if(COMMAND deploy_plugins_if_qt)
                deploy_plugins_if_qt("${baseTargetBinaryDir}" "${installedDirRoot}/plugins" "${lib}")
            endif()
            math(EXPR stacks "${stacks}+1")
            resolve("${baseTargetBinaryDir}/${lib}")
            math(EXPR stacks "${stacks}-1")
        elseif(EXISTS "${targetBinaryDir}/${lib}")
            message(VERBOSE "${lib}: ${lib} not found in vcpkg; locally deployed")
            math(EXPR stacks "${stacks}+1")
            resolve("${targetBinaryDir}/${lib}")
            math(EXPR stacks "${stacks}-1")
        else()
            message(VERBOSE "${lib}: ${sourceDir}/${lib} not found")
        endif()
    endforeach()

    if(stacks EQUAL 0)
        message("Copying dependencies to ${baseTargetBinaryDir} Done")
    endif()
    set(stacks ${stacks} PARENT_SCOPE)
endfunction()

include("${installedDirRoot}/plugins/qtdeploy.cmake" OPTIONAL)

resolve(${APPLOCAL_targetBinary})
list(POP_BACK CMAKE_MESSAGE_CONTEXT)
