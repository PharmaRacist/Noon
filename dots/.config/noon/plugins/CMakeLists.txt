qt_add_qml_module(noon
    URI Noon
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon"
    SOURCES
        widgets/highlighter.h
        widgets/highlighter.cpp
        widgets/cava_watcher.h
        widgets/cava_watcher.cpp
        services/addblocker.h
        services/addblocker.cpp
        services/latex.cpp
        services/latex.h
        services/clipboard.h
        services/clipboard.cpp
    QML_FILES
)

target_include_directories(noon PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/widgets"
    "${CMAKE_CURRENT_SOURCE_DIR}/services"
)

target_link_libraries(noon PRIVATE
    Qt6::Quick
    Qt6::WebView
    Qt6::WebEngineCore
    Qt6::WebEngineQuick
    Qt6::Sql
)

# Optional MicroTeX support
find_library(MICROTEX_LIBRARY NAMES microtex microTeX MicroTeX)
find_path(MICROTEX_INCLUDE_DIR NAMES latex.h)

if(MICROTEX_LIBRARY AND MICROTEX_INCLUDE_DIR)
    message(STATUS "Found MicroTeX: ${MICROTEX_LIBRARY}")
    target_link_libraries(noon PRIVATE ${MICROTEX_LIBRARY})
    target_include_directories(noon PRIVATE ${MICROTEX_INCLUDE_DIR})
    target_compile_definitions(noon PRIVATE MICROTEX_LINKED)
else()
    message(STATUS "MicroTeX not found - using process-based rendering")
endif()

# Installation
if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon noonplugin DESTINATION "${QML_INSTALL_DIR}/Noon")

qt_query_qml_module(noon QMLDIR qmldir_file TYPEINFO typeinfo_file)
install(FILES ${qmldir_file} ${typeinfo_file} DESTINATION "${QML_INSTALL_DIR}/Noon")
