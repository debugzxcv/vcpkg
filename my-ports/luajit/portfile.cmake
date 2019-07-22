if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "LuaJIT currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WohlSoft/LuaJIT
    REF v2.1
    SHA512 dbd88bfe57adf66dbaa122cf0e29d9e77c840c578f9ce6b7e387ab88cd82ed1bcd26eb4c5ee56360188da9220dc6626c87bf066343e1f5236a07bcc7408a6a8b
    HEAD_REF v2.1
    PATCHES
        9999-mssdk+llvm-toolset-build.patch
        9998-install.patch
        9997-options.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        52compat LUAJIT_ENABLE_LUA52COMPAT
        utf8fopen LUAJIT_FORCE_UTF8_FOPEN
    INVERTED_FEATURES
        tool LUAJIT_SKIP_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME ${PORT})
