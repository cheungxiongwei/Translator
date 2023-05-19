cmake_minimum_required(VERSION 3.16)

project(Translator VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Network Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(Translator
    main.cpp
    "${CMAKE_CURRENT_SOURCE_DIR}/favicon.rc"
)

qt_add_qml_module(Translator
    URI Translator
    VERSION 1.0
    QML_FILES Main.qml
    SOURCES
    Translator.h Translator.cpp
)

qt_add_resources(Translator "controls_conf"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
        favicon.ico
)

set_target_properties(Translator PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Translator
    PRIVATE Qt6::Network Qt6::Quick Qt6::QuickControls2
)

install(TARGETS Translator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
