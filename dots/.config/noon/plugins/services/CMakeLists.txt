qt_add_qml_module(noon_services
    URI Noon.Services
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon/Services"
    SOURCES
        clipboard.hpp
        clipboard.cpp
        resources.hpp
        resources.cpp
)

target_link_libraries(noon_services PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Concurrent
)

if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon_services noon_servicesplugin DESTINATION "${QML_INSTALL_DIR}/Noon/Services")
qt_query_qml_module(noon_services QMLDIR qmldir_services TYPEINFO typeinfo_services)
install(FILES ${qmldir_services} ${typeinfo_services} DESTINATION "${QML_INSTALL_DIR}/Noon/Services")
