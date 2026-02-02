qt_add_qml_module(noon
    URI Noon
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon"
    SOURCES
        utils/highlighter.hpp
        utils/highlighter.cpp

        utils/cava_watcher.hpp
        utils/cava_watcher.cpp

        utils/hyprparser.hpp
        utils/hyprparser.cpp

        services/clipboard.hpp
        services/clipboard.cpp
        services/resources.hpp
        services/resources.cpp

    QML_FILES
)

target_include_directories(noon PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/utils"
    "${CMAKE_CURRENT_SOURCE_DIR}/services"
)

target_link_libraries(noon PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Concurrent
)

# Installation
if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon noonplugin DESTINATION "${QML_INSTALL_DIR}/Noon")

qt_query_qml_module(noon QMLDIR qmldir_file TYPEINFO typeinfo_file)
install(FILES ${qmldir_file} ${typeinfo_file} DESTINATION "${QML_INSTALL_DIR}/Noon")
