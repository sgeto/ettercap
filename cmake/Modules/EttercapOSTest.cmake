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
  message(WARNING "Ettercap's Windows port is still in development.")
  set(OS_WINDOWS 1)
  if(${CMAKE_COMPILER_IS_GNUCC} MATCHES "1")
    set(OS_MINGW 1)
  endif()
elseif(CYGWIN)
message(WARNING "Ettercap's Cygwin port is unmaintained.")
  set(OS_CYGWIN 1)
  set(OS_WINDOWS 1)
else()
  message(FATAL_ERROR "Operating system not supported.")
endif()

set(OS_SIZEOF_P ${CMAKE_SIZEOF_VOID_P})

include(TestBigEndian)

test_big_endian(WORDS_BIGENDIAN)

set(CC_VERSION ${CMAKE_C_COMPILER})
