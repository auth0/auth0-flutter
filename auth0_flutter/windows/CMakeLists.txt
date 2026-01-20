# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0167 NEW)
project(auth0_flutter LANGUAGES CXX)

#if (DEFINED ENV{VCPKG_ROOT} AND EXISTS "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
#    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
#        CACHE STRING "Vcpkg toolchain file")
#endif()

# Project-level configuration.
set(PROJECT_NAME "auth0_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "auth0_flutter_plugin")
# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "auth0_flutter_plugin.cpp"
  "auth0_flutter_plugin.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/auth0_flutter/auth0_flutter_plugin_c_api.h"
  "auth0_flutter_plugin_c_api.cpp"
  "auth0_client.cpp"
  "token_decoder.cpp"
  "time_util.cpp"
  "user_profile.cpp"
  "user_identity.cpp"
  "jwt_util.cpp"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_compile_definitions(${PLUGIN_NAME}
  PRIVATE
    _SILENCE_STDEXT_ARR_ITERS_DEPRECATION_WARNING
)
# Source include directories and library dependencies.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

#list(APPEND CMAKE_MODULE_PATH "$ENV{VCPKG_ROOT}/installed/x64-windows/share")

# === vcpkg dependencies ===
# These are resolved via vcpkg.json automatically (cpprestsdk, boost)
find_package(cpprestsdk CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system date_time regex)

# Link Flutter + vcpkg dependencies
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  cpprestsdk::cpprest
  OpenSSL::SSL
  OpenSSL::Crypto
  Boost::system
  Boost::date_time
  Boost::regex
)

# List of absolute paths to libraries that should be bundled with the plugin.
set(auth0_flutter_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===
option(AUTH0_FLUTTER_ENABLE_TESTS "Build auth0_flutter unit tests" ON)

if (AUTH0_FLUTTER_ENABLE_TESTS)
  enable_testing()

  set(TEST_RUNNER auth0_flutter_tests)

  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/release-1.11.0.zip
  )
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)

  add_executable(${TEST_RUNNER}
    test/jwt_util_test.cpp
    test/time_util_test.cpp
    test/token_decoder_test.cpp
    test/user_identity_test.cpp
    test/user_profile_test.cpp

    # Reuse plugin sources directly (NO flutter plugin entrypoints)
    auth0_client.cpp
    token_decoder.cpp
    time_util.cpp
    user_profile.cpp
    user_identity.cpp
    jwt_util.cpp
  )

  target_compile_features(${TEST_RUNNER} PRIVATE cxx_std_17)

  target_include_directories(${TEST_RUNNER} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
  )

  target_link_libraries(${TEST_RUNNER} PRIVATE
    flutter_wrapper_plugin
    gtest_main
    gmock
    cpprestsdk::cpprest
    OpenSSL::SSL
    OpenSSL::Crypto
    Boost::system
    Boost::date_time
    Boost::regex
  )

  include(GoogleTest)
  gtest_discover_tests(${TEST_RUNNER})
endif()