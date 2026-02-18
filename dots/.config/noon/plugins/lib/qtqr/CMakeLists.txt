cmake_minimum_required(VERSION 3.16)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Svg
)

file(GLOB_RECURSE QT_QR_SRC_FILES
    "src/*.cpp"
)

add_library(qtqr STATIC
    ${QT_QR_SRC_FILES}
)

set_target_properties(qtqr PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)

target_include_directories(qtqr PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(qtqr PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Svg
)

target_compile_definitions(qtqr PUBLIC
    BUILD_QT
)
