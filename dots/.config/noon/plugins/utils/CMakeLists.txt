qt_add_qml_module(noon_utils
    URI Noon.Utils
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon/Utils"
    SOURCES
        highlighter.hpp
        highlighter.cpp
        cava_watcher.hpp
        cava_watcher.cpp
        hyprparser.hpp
        hyprparser.cpp
)

target_link_libraries(noon_utils PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Concurrent
)

# Installation
if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon_utils noon_utilsplugin DESTINATION "${QML_INSTALL_DIR}/Noon/Utils")
qt_query_qml_module(noon_utils QMLDIR qmldir_utils TYPEINFO typeinfo_utils)
install(FILES ${qmldir_utils} ${typeinfo_utils} DESTINATION "${QML_INSTALL_DIR}/Noon/Utils")

add_subdirectory(latex)
add_subdirectory(qr)
