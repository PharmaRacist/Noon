qt_add_qml_module(noon_utils_qr
    URI Noon.Utils.Qr
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon/Utils/Qr"
    SOURCES
    
    qrcode.cpp
    qrcode.hpp
)

target_include_directories(noon_utils_qr  PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/qtqr/src"
)
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Svg
)

target_link_libraries(noon_utils_qr  PRIVATE
    Qt6::Quick
    Qt6::Svg
    qtqr
)

if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon_utils_qr  noon_utils_qrplugin DESTINATION "${QML_INSTALL_DIR}/Noon/Utils/Qr")
qt_query_qml_module(noon_utils_qr  QMLDIR qmldir_qr TYPEINFO typeinfo_qr)
install(FILES ${qmldir_qr} ${typeinfo_qr} DESTINATION "${QML_INSTALL_DIR}/Noon/Utils/Qr")
