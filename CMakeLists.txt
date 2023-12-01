cmake_minimum_required(VERSION 3.16)

project(
  Translator
  VERSION 0.1
  LANGUAGES CXX)

# 启用自动处理 UI 文件、MOC 和资源文件
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# 引入自定义函数文件
include(cmake/AddQMLSubdirectories.cmake)

# 在需要的地方调用函数
add_subdirectories_to_qml_import_path("${CMAKE_CURRENT_LIST_DIR}")

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Network Qml
                                                  QuickControls2 LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED
             COMPONENTS Core Quick Network Qml QuickControls2 LinguistTools)

set(SOURCES app/main.cpp app/src/Translator.h app/src/Translator.cpp)

qt_add_resources(SOURCES app/qml.qrc)

add_executable(Translator app/favicon.rc ${SOURCES}
    app/assets.qrc)

qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

# qt_add_resources( Translator "controls_conf" PREFIX "/" FILES
# qtquickcontrols2.conf favicon.ico)

set_target_properties(
  Translator
  PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
             MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING
             ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
             MACOSX_BUNDLE TRUE
             WIN32_EXECUTABLE TRUE)

target_compile_options(Translator PRIVATE "$<$<CXX_COMPILER_ID:MSVC>:/ utf-8>")

if(MSVC)
  target_compile_options(Translator PRIVATE /W4)
endif()

target_compile_definitions(Translator PRIVATE QT_QML_DEBUG)

target_include_directories(
  Translator
  PRIVATE "${CMAKE_CURRENT_LIST_DIR};${CMAKE_CURRENT_LIST_DIR}/app/src")

target_link_libraries(
  Translator
  PRIVATE Qt${QT_VERSION_MAJOR}::CorePrivate Qt${QT_VERSION_MAJOR}::Network
          Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Qml
          Qt${QT_VERSION_MAJOR}::QuickControls2Private)

install(
  TARGETS Translator
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
