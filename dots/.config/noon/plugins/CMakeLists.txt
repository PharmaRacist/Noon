add_subdirectory(lib/microtex)
add_subdirectory(lib/qtqr)
add_subdirectory(utils)
add_subdirectory(services)

qt_add_qml_module(noon
    URI Noon
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon"
)

target_link_libraries(noon PRIVATE Qt6::Quick)

if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon noonplugin DESTINATION "${QML_INSTALL_DIR}/Noon")
qt_query_qml_module(noon QMLDIR qmldir_file TYPEINFO typeinfo_file)
install(FILES ${qmldir_file} ${typeinfo_file} DESTINATION "${QML_INSTALL_DIR}/Noon")
