cmake_minimum_required(VERSION 3.24)
project(todo-cli VERSION 1.0 LANGUAGES C)

include(GNUInstallDirs)

# Build types
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${PROJECT_INCLUDE_DIR})

file(GLOB SRC_FILES src/*.c)

# Create library from sources (exclude main.c if present)
set(LIB_SOURCES "")
foreach(f ${SRC_FILES})
  get_filename_component(fname ${f} NAME)
  if(NOT fname STREQUAL "main.c")
    list(APPEND LIB_SOURCES ${f})
  endif()
endforeach()

add_library(todo_lib STATIC ${LIB_SOURCES})
target_compile_features(todo_lib PUBLIC c_std_23)
target_include_directories(todo_lib PUBLIC ${PROJECT_INCLUDE_DIR})

# Executable
add_executable(todo src/main.c)
target_link_libraries(todo PRIVATE todo_lib)

set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR})
install(TARGETS todo RUNTIME DESTINATION ${INSTALL_BIN_DIR})

# Formatting and linting targets (local only)
find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
  file(GLOB_RECURSE ALL_SOURCES CONFIGURE_DEPENDS
    ${PROJECT_INCLUDE_DIR}/*.h
    src/*.c)
  add_custom_target(format
    COMMAND ${CLANG_FORMAT} -i ${ALL_SOURCES}
    COMMENT "Apply clang-format to sources"
  )
endif()

# Simple cppcheck target if available
find_program(CPPCHECK cppcheck)
if(CPPCHECK)
  add_custom_target(cppcheck
    COMMAND ${CPPCHECK} --enable=all --inconclusive --quiet ${PROJECT_INCLUDE_DIR} src
    COMMENT "Run cppcheck"
  )
endif()

# Add testing support with Check (if present locally)
find_package(Check QUIET)
if(Check_FOUND)
  enable_testing()
  file(GLOB TEST_SOURCES tests/*.c)
  add_executable(test_todo ${TEST_SOURCES})
  target_link_libraries(test_todo PRIVATE todo_lib Check::Check)
  add_test(NAME todo_tests COMMAND test_todo)
else()
  # Fallback: if Check not found, build simple_tests.c as a smoke test
  if(EXISTS ${CMAKE_SOURCE_DIR}/tests/simple_tests.c)
    add_executable(smoke_tests tests/simple_tests.c)
    target_link_libraries(smoke_tests PRIVATE todo_lib)
    add_custom_target(run-smoke
      COMMAND smoke_tests
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Run simple smoke tests"
    )
  endif()
endif()

# Build flags for special Test configuration
if(CMAKE_BUILD_TYPE STREQUAL "Test")
  message(STATUS "Configuring Test build (sanitizers enabled)")
  if(CMAKE_C_COMPILER_ID MATCHES "Clang" OR CMAKE_C_COMPILER_ID MATCHES "GNU")
    add_compile_options(-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer)
    # Do not attempt static linking for sanitizer builds
    string(REPLACE "-static" "" CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
  endif()
endif()

# Find Lua interpreter for scripts
find_program(LUAJIT_EXE luajit)
find_program(LUA_EXE lua)
if(LUAJIT_EXE)
  set(LUA_EXE_CMD ${LUAJIT_EXE})
elseif(LUA_EXE)
  set(LUA_EXE_CMD ${LUA_EXE})
else()
  set(LUA_EXE_CMD "")
endif()

# Verify lua executable can run the generator at configure time. If it cannot,
# do not create the build target to avoid failing builds when luajit is a shim
# that cannot be executed in this environment.
if(LUA_EXE_CMD)
  execute_process(COMMAND ${LUA_EXE_CMD} --version
                  RESULT_VARIABLE LUA_RUN_OK
                  OUTPUT_QUIET ERROR_QUIET)
  if(LUA_RUN_OK EQUAL 0)
    add_custom_target(update-agents-doc
      COMMAND ${LUA_EXE_CMD} ${CMAKE_SOURCE_DIR}/scripts/generate_agents.lua
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generate AGENTS.md using Lua script"
    )
  else()
    message(STATUS "Found lua (${LUA_EXE_CMD}) but it cannot be executed here; update-agents-doc disabled")
  endif()
else()
  message(STATUS "Lua not found; update-agents-doc target disabled")
endif()

# Packaging target (local only)
set(PKG_NAME "todo-${PROJECT_VERSION}")
add_custom_target(package-local
  COMMAND ${CMAKE_COMMAND} -E tar cfv ${PKG_NAME}.tar.gz
          ${CMAKE_BINARY_DIR}/todo.exe ${CMAKE_SOURCE_DIR}/AGENTS.md ${CMAKE_SOURCE_DIR}/README.md
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  COMMENT "Create local tar.gz package"
)

# BOLT workflow (placeholders; requires llvm-bolt and perf)
add_custom_target(profile-build
  COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Release
  COMMENT "Build instrumented binary for profiling (manual steps may be required)"
)

add_custom_target(run-profile
  COMMAND ${LUA_EXE_CMD} ${CMAKE_SOURCE_DIR}/scripts/run_profile_workload.lua ${CMAKE_BINARY_DIR}/todo.exe
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMENT "Run profile workload to generate data for BOLT"
  VERBATIM
)

add_custom_target(bolt-opt
  COMMENT "Run llvm-bolt optimization (user must run manually with correct flags)"
)
