if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(OS_LINUX 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
    set(OS_BSD 1)
    set(OS_BSD_FREE 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "NetBSD")
    set(OS_BSD 1)
    set(OS_BSD_NET 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "OpenBSD")
    set(OS_BSD 1)
    set(OS_BSD_OPEN 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(OS_DARWIN 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "SunOS")
    set(OS_SOLARIS 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "GNU")
    set(OS_GNU 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
message(WARNING "Ettercap's Windows port is still in development. Be aware.")
    set(OS_WINDOWS 1)
    if (${CMAKE_COMPILER_IS_GNUCC} MATCHES "1")
        set(OS_MINGW 1)
    endif()
elseif(CYGWIN)
message(WARNING "Ettercap's Cygwin port is unmaintained.")
    set(OS_CYGWIN 1)
    set(OS_WINDOWS 1)
else()
    message(FATAL_ERROR "Operating system not supported")
endif()

set(OS_SIZEOF_P ${CMAKE_SIZEOF_VOID_P})

include(TestBigEndian)

TEST_BIG_ENDIAN(WORDS_BIGENDIAN)

set(CC_VERSION ${CMAKE_C_COMPILER})

if(OS_WINDOWS)
  set(gid_t int)
  set(uid_t int)
  set(uint unsigned int)
  
  add_definitions(-DWIN32_LEAN_AND_MEAN)
  # add_definitions(-D_WIN32_WINNT=0x0501)
  
  if(ENABLE_GTK)
    find_package(PkgConfig REQUIRED)
  endif(ENABLE_GTK)
  # Additional compiler and linker flags for windows should be set here *only*.
  if(MINGW)
    if(CMAKE_BUILD_TYPE STREQUAL Release)
      set(CMAKE_RC_FLAGS "-Iinclude -v" CACHE STRING "" FORCE)
    elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
      set(CMAKE_RC_FLAGS "-Iinclude -v" CACHE STRING "" FORCE)
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
      set(CMAKE_RC_FLAGS "-D_DEBUG -Iinclude -v" CACHE STRING "" FORCE)
    endif(CMAKE_BUILD_TYPE STREQUAL Release)

    set(CMAKE_C_STANDARD_LIBRARIES "-lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -lws2_32" CACHE STRING "" FORCE)

    set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--output-def, -Wl,${PROJECT_NAME}.def -Wl,--warn-common -Wl,--no-as-needed -Wl,--nxcompat -Wl,--dynamicbase" CACHE STRING "" FORCE)

    set(CMAKE_EXE_LINKER_FLAGS "-Wl,--subsystem -Wl,windows" CACHE STRING "" FORCE)

  elseif(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)

    set(CMAKE_C_FLAGS "/DWIN32 /D_WINDOWS /W3 /nologo /errorReport:none /GS-" CACHE STRING "" FORCE)

    if(CMAKE_BUILD_TYPE STREQUAL Release)
    set(CMAKE_RC_FLAGS "/DWIN32 /D__NOTMINGW__ /Iinclude /v" CACHE STRING "" FORCE)
    elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
    set(CMAKE_RC_FLAGS "/DWIN32 /D__NOTMINGW__ /Iinclude /v" CACHE STRING "" FORCE)
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(CMAKE_RC_FLAGS "/DWIN32 /D_DEBUG /D__NOTMINGW__ /Iinclude /v" CACHE STRING "" FORCE)
    endif(CMAKE_BUILD_TYPE STREQUAL Release)

    set(CMAKE_C_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib ws2_32.lib" CACHE STRING "" FORCE)

    set(CMAKE_SHARED_LINKER_FLAGS "/machine:${MSVC_C_ARCHITECTURE_ID} /nologo /NXCOMPAT /DYNAMICBASE /DELAYLOAD:wpcap.dll /ERRORREPORT:NONE" CACHE STRING "" FORCE)

    set(CMAKE_EXE_LINKER_FLAGS "/machine:${MSVC_C_ARCHITECTURE_ID} ${CMAKE_CREATE_CONSOLE_EXE}" CACHE STRING "" FORCE)

    include(FindZLIB)
    include(FindPthreads)
    include(FindIconv)
    include(FindCURL)
    include(FindPCAP)
    include(FindLIBNET)
  endif(MSVC)
endif(OS_WINDOWS)
