# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "auth0_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 OLD)
endif()

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

# Source include directories and library dependencies.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

# === Dependencies ===
find_package(cpprestsdk CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)

# Find Boost manually for compatibility with system packages
# Note: boost_system is header-only in Boost 1.69+
find_path(BOOST_INCLUDE_DIR boost/version.hpp REQUIRED)
find_library(BOOST_DATE_TIME_LIB NAMES boost_date_time REQUIRED)
find_library(BOOST_REGEX_LIB NAMES boost_regex REQUIRED)

# Link Flutter + dependencies
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  PkgConfig::GTK
  cpprestsdk::cpprest
  OpenSSL::SSL
  OpenSSL::Crypto
  ${BOOST_DATE_TIME_LIB}
  ${BOOST_REGEX_LIB}
)

target_include_directories(${PLUGIN_NAME} PRIVATE ${BOOST_INCLUDE_DIR})

# List of absolute paths to libraries that should be bundled with the plugin.
set(auth0_flutter_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===
if (${include_${PROJECT_NAME}_tests})
  set(TEST_RUNNER "${PROJECT_NAME}_test")
  enable_testing()

  # Add the Google Test dependency
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/release-1.11.0.zip
  )
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
  FetchContent_MakeAvailable(googletest)

  # Build test runner
  add_executable(${TEST_RUNNER}
    test/auth0_flutter_plugin_test.cpp
    ${PLUGIN_SOURCES}
  )
  apply_standard_settings(${TEST_RUNNER})
  target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
  target_link_libraries(${TEST_RUNNER} PRIVATE
    flutter_wrapper_plugin
    gtest_main
    gmock
  )

  include(GoogleTest)
  gtest_discover_tests(${TEST_RUNNER})
endif()
