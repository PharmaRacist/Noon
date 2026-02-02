cmake_minimum_required(VERSION 3.21)
project(Noon VERSION 1.0 LANGUAGES CXX)
find_package(
    Qt6
    REQUIRED
    COMPONENTS
    Core
    Gui
    Qml
    Quick
    Sql
)
qt_standard_project_setup(REQUIRES 6.5)
add_subdirectory(plugins)
