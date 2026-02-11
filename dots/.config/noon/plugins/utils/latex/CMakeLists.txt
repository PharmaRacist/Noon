qt_add_qml_module(noon_utils_latex
    URI Noon.Utils.Latex
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Noon/Utils/Latex"
    SOURCES
        latex_renderer.hpp
        latex_renderer.cpp
)

target_include_directories(noon_utils_latex PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/microtex/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/microtex/res"
)

target_link_libraries(noon_utils_latex PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Concurrent
    microtex
)

# Installation
if(NOT QML_INSTALL_DIR)
    set(QML_INSTALL_DIR "${QT6_INSTALL_PREFIX}/lib/qt6/qml" CACHE PATH "QML install dir")
endif()

install(TARGETS noon_utils_latex noon_utils_latexplugin DESTINATION "${QML_INSTALL_DIR}/Noon/Utils/Latex")
qt_query_qml_module(noon_utils_latex QMLDIR qmldir_latex TYPEINFO typeinfo_latex)
install(FILES ${qmldir_latex} ${typeinfo_latex} DESTINATION "${QML_INSTALL_DIR}/Noon/Utils/Latex")
