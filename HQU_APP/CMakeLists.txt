cmake_minimum_required(VERSION 3.20)

set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum OS X deployment version")

project(HQU_Assistant VERSION 1.0.0 LANGUAGES CXX)

set(PROJECT_COMPANY "Mentalflow's Lab")
set(PROJECT_COPYRIGHT "Copyright (c) 2023 Mentalflow's Lab. All rights reserved.")
set(PROJECT_DOMAIN "dev.ourdocs.cn.hqua")
if(WIN32)
    set(PROJECT_BUNDLE_NAME HQU-Assistant)
else()
    set(PROJECT_BUNDLE_NAME HQU助手)
endif()

add_definitions(-DHQUA_VERSION=1,0,0,5)

#配置通用编译
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "[macOS]: Universal Build." FORCE)
endif()

#设置可执行文件输出目录
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/app/debug)
else()
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/app/release)
endif()

#获取文件路径分隔符（解决执行命令的时候有些平台会报错）
file(TO_CMAKE_PATH "/" PATH_SEPARATOR)

find_package(Qt6 REQUIRED COMPONENTS Quick REQUIRED)

#遍历所有Cpp文件
include_directories(include include/fileio include/language include/qmlhttprequest)
file(GLOB_RECURSE CPP_FILES *.cpp *.h *.hpp)
foreach(filepath ${CPP_FILES})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    list(APPEND sources_files ${filename})
endforeach(filepath)

#遍历所有qml文件
file(GLOB_RECURSE QML_PATHS *.qml)
foreach(filepath ${QML_PATHS})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    list(APPEND qml_files ${filename})
endforeach(filepath)

#遍历所有资源文件
file(GLOB_RECURSE RES_PATHS *.png *.jpg *.svg *.ico *.ttf *.webp qmldir)
foreach(filepath ${RES_PATHS})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    list(APPEND resource_files ${filename})
endforeach(filepath)

#添加可执行文件
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/res/icon.rc")
    qt_add_executable(${PROJECT_NAME}
        ${sources_files}
        "${CMAKE_CURRENT_SOURCE_DIR}/res/icon.rc"
    )
elseif(APPLE)
    set(MACOSX_BUNDLE_ICON_FILE AppIcon)
    set(App_ICON "${CMAKE_CURRENT_SOURCE_DIR}/res/image/AppIcon.icns")
    set_source_files_properties(${App_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    qt_add_executable(${PROJECT_NAME}
        ${sources_files}
        ${App_ICON}
    )
else ()
    qt_add_executable(${PROJECT_NAME}
        ${sources_files}
    )
endif ()

#复制动态库到可执行文件同级目录下
if(WIN32)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(DLLPATH ${CMAKE_SOURCE_DIR}/3rdparty/msvc/*.dll)
    else()
        set(DLLPATH ${CMAKE_SOURCE_DIR}/3rdparty/mingw/*.dll)
    endif()
    string(REPLACE "/" ${PATH_SEPARATOR} DLLPATH "${DLLPATH}")
    file(GLOB DLL_FILES ${DLLPATH})
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${DLL_FILES}
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    )
endif()

#添加qml模块
qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    QML_FILES ${qml_files}
    RESOURCES ${resource_files}
)

#设置属性
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER ${PROJECT_DOMAIN}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_BUNDLE_NAME}
    MACOSX_BUNDLE_COPYRIGHT ${PROJECT_COPYRIGHT}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    OUTPUT_NAME ${PROJECT_BUNDLE_NAME}
)

#链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
    fluentuiplugin
    FramelessHelper::Core
    FramelessHelper::Quick
)

#安装
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
