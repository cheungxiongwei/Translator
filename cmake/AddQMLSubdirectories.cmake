# 定义添加子目录到 QML_IMPORT_PATH 的函数
function(add_subdirectories_to_qml_import_path DIRECTORY)
  file(
    GLOB_RECURSE SUBDIRS
    LIST_DIRECTORIES true
    "${DIRECTORY}/*")

  foreach(subdir ${SUBDIRS})
    if(IS_DIRECTORY ${subdir})
      list(APPEND QML_IMPORT_PATH "${subdir}")
    endif()
  endforeach()

  # Prevent adding duplicate values at each run of CMake.
  list(REMOVE_DUPLICATES QML_IMPORT_PATH)

  # Set the QML_IMPORT_PATH variable and cache it in CMakeCache.txt immediately.
  set(QML_IMPORT_PATH
      ${QML_IMPORT_PATH}
      CACHE STRING "Qt Creator 12.0 extra qml import paths" FORCE)
endfunction()
