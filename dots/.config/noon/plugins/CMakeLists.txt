# This creates both the 'noon' library and the 'noonplugin'
qt_add_qml_module(noon
    URI Noon
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon"
    SOURCES
        src/highlighter.h
        src/highlighter.cpp
    QML_FILES
)
target_include_directories(noon PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(noon PRIVATE
    Qt6::Quick
    Qt6::WebView
)

if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

# Install everything into /usr/lib/qt6/qml/Noon/
install(TARGETS noon noonplugin
    DESTINATION "${QML_INSTALL_DIR}/Noon")

qt_query_qml_module(noon QMLDIR qmldir_file TYPEINFO typeinfo_file)
install(FILES ${qmldir_file} ${typeinfo_file}
    DESTINATION "${QML_INSTALL_DIR}/Noon")
