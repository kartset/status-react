if(WIN32)
  # Download automatically, you can also just copy the conan.cmake file
  # TODO: Create packages of qt5 for Linux and MacOS too, so that we can rely strictly on this branch of code 
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
      message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
      file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
                    "${CMAKE_BINARY_DIR}/conan.cmake")
  endif()

  include(${CMAKE_BINARY_DIR}/conan.cmake)

  conan_check()

  conan_cmake_run(REQUIRES qt5-mxe/5.11.2@status-im/experimental
                  PROFILE $ENV{STATUS_REACT_HOME}/../status-conan/profiles/status-mxe-mingw32-x86_64-gcc55-libstdcxx # TODO Remove hardcoded path
                  BASIC_SETUP
                  SETTINGS "qt5-mxe:os=Windows qt5-mxe:arch=x86_64"
                  OPTIONS "qt5-mxe:webkit=True"
                  BUILD missing outdated)

  set(QTROOT "${CONAN_QT5-MXE_ROOT}/gcc_64")
else(WIN32)
  set(QTROOT "$ENV{QT_PATH}/gcc_64")
endif(WIN32)

if(NOT EXISTS ${QTROOT}/bin/qt.conf)
  message(FATAL_ERROR "Could not find qt.conf in ${QTROOT}/bin. Is QTROOT correctly defined?")
endif()

if(WIN32)
  set(WINARCHSTR ARCHSTR windows-x86_64)
endif(WIN32)

message(STATUS "Qt root directory: ${QTROOT}")

list(APPEND CMAKE_FIND_ROOT_PATH ${QTROOT})
list(APPEND CMAKE_PREFIX_PATH ${QTROOT})
include_directories(${QTROOT}/include)

set(REQUIRED_QT_VERSION "5.9.1")

set(QTCONFIGROOT ${QTROOT}/lib/cmake/Qt5)

foreach(COMP ${USED_QT_MODULES})
  set(mod Qt5${COMP})

  # look for the config files in the QtConfigRoot defined above
  set(${mod}_DIR ${QTCONFIGROOT}${COMP})

  # look for the actual package
  find_package(${mod} ${REQUIRED_QT_VERSION} REQUIRED)

  #message("${mod}_INCLUDE_DIRS: include_directories(${${mod}_INCLUDE_DIRS})")
  include_directories(${${mod}_INCLUDE_DIRS})

  list(APPEND QT5_LIBRARIES ${${mod}_LIBRARIES})
  list(APPEND QT5_CFLAGS ${${mod}_EXECUTABLE_COMPILE_FLAGS})
endforeach(COMP ${USED_QT_MODULES})

if(QT5_CFLAGS)
	list(REMOVE_DUPLICATES QT5_CFLAGS)
  if(WIN32)
    list(REMOVE_ITEM QT5_CFLAGS -fPIC)
  endif(WIN32)
endif(QT5_CFLAGS)

# message(STATUS "Qt version: ${Qt5Core_VERSION_STRING}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${QT5_CFLAGS}")
# message("CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
# message("QT5_LIBRARIES=${QT5_LIBRARIES}")

#set(CMAKE_REQUIRED_INCLUDES ${Qt5WebEngine_INCLUDE_DIRS};${Qt5WebEngine_PRIVATE_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${QT5_LIBRARIES})