cmake_minimum_required(VERSION 3.16)

# Collect all source files recursively
file(GLOB_RECURSE MICROTEX_SRC_FILES
    "src/*.cpp"
)

# Collect all resource files
file(GLOB_RECURSE MICROTEX_RES_FILES
    "res/builtin/*.cpp"
    "res/font/*.cpp"
    "res/sym/*.cpp"
    "res/reg/*.cpp"
    "res/parser/*.cpp"
)

# Create the MicroTeX library
add_library(microtex STATIC
    ${MICROTEX_SRC_FILES}
    ${MICROTEX_RES_FILES}
)

# CRITICAL: Enable Position Independent Code for linking into shared library
set_target_properties(microtex PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)

target_include_directories(microtex PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/res
)

target_link_libraries(microtex PUBLIC
    Qt6::Core
    Qt6::Gui
)

# CRITICAL: Define BUILD_QT to enable Qt graphics support
target_compile_definitions(microtex PUBLIC
    BUILD_QT
    MICROTEX_RES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/res"
)
