# ==============================================================================
# This is a modified version of FindPthreads.cmake for the ettercap project.
# I'm not sure who the original author of this module is. I took it from this
# repo:
#
# https://github.com/percolator/percolator
#
# If you must know who owns the copyright on it, you might want to start there.
#
# Apart from this notice, this module "enjoys" the following modifications:
#
# - users may be able to use the environment variable PTHREADS_ROOT to point
#   cmake to the *root* of their Pthreads installation.
#   Alternatively, PTHREADS_ROOT may also be set from cmake command line or GUI
#   (-DPTHREADS_ROOT=/path/to/pthreads)
#
# - added some additional status/error messages
#
# - when searching for pthreads-win32 libraries, the directory structure of the
#   pre-build binaries folder found in the pthreads-win32 CVS code repository is
#   considered (e.i /Pre-built.2/lib/x64 /Pre-built.2/lib/x86)
#
# Send suggestion, patches, gifts and praises to the ettercap developers.
# ==============================================================================
#
# Find the Pthreads library
# This module searches for the Pthreads library (including the
# pthreads-win32 port).
#
# This module defines these variables:
#
#  PTHREADS_FOUND       - True if the Pthreads library was found
#  PTHREADS_LIBRARY     - The location of the Pthreads library
#  PTHREADS_INCLUDE_DIR - The include directory of the Pthreads library
#  PTHREADS_DEFINITIONS - Preprocessor definitions to define (HAVE_PTHREAD_H is a fairly common one)
#
# This module responds to the PTHREADS_EXCEPTION_SCHEME
# variable on Win32 to allow the user to control the
# library linked against.  The Pthreads-win32 port
# provides the ability to link against a version of the
# library with exception handling.	IT IS NOT RECOMMENDED
# THAT YOU CHANGE PTHREADS_EXCEPTION_SCHEME TO ANYTHING OTHER THAN
# "C" because most POSIX thread implementations do not support stack
# unwinding.
#
#  PTHREADS_EXCEPTION_SCHEME
#	   C  = no exceptions (default)
#		  (NOTE: This is the default scheme on most POSIX thread
#		   implementations and what you should probably be using)
#	   CE = C++ Exception Handling
#	   SE = Structure Exception Handling (MSVC only)
#

#
# Define a default exception scheme to link against
# and validate user choice.
#
# Hints
# =====
# Users may set the (environment) variable ``PTHREADS_ROOT`` to a Pthreads
# installation root to tell this module where to look.
#
IF(NOT DEFINED PTHREADS_EXCEPTION_SCHEME)
	# Assign default if needed
	SET(PTHREADS_EXCEPTION_SCHEME "C")
ELSE(NOT DEFINED PTHREADS_EXCEPTION_SCHEME)
	# Validate
	IF(NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "C" AND
	   NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "CE" AND
	   NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "SE")

	MESSAGE(FATAL_ERROR "See documentation for FindPthreads.cmake, only C, CE, and SE modes are allowed")

	ENDIF(NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "C" AND
		  NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "CE" AND
		  NOT PTHREADS_EXCEPTION_SCHEME STREQUAL "SE")

	 IF(NOT MSVC AND PTHREADS_EXCEPTION_SCHEME STREQUAL "SE")
		 MESSAGE(FATAL_ERROR "Structured Exception Handling is only allowed for MSVC")
	 ENDIF(NOT MSVC AND PTHREADS_EXCEPTION_SCHEME STREQUAL "SE")

ENDIF(NOT DEFINED PTHREADS_EXCEPTION_SCHEME)

if(PTHREADS_ROOT)
  set(PTHREADS_ROOT PATHS ${PTHREADS_ROOT} NO_DEFAULT_PATH)
else()
  set(PTHREADS_ROOT $ENV{PTHREADS_ROOT})
endif(PTHREADS_ROOT)

#
# Find the header file
#
FIND_PATH(PTHREADS_INCLUDE_DIR
          NAMES pthread.h
	  HINTS
	  /usr/include
	  /usr/local/include
	  $ENV{PTHREAD_INCLUDE_PATH}
	  ${PTHREADS_ROOT}/include
	  )

IF(PTHREADS_INCLUDE_DIR)
message(STATUS "Found pthread.h: ${PTHREADS_INCLUDE_DIR}")
ELSE()
message(FATAL_ERROR "Could not find pthread.h. See README.PLATFORMS for more information.")
ENDIF(PTHREADS_INCLUDE_DIR)
#
# Find the library
#
SET(names)
IF(MSVC)
	SET(names
			pthreadV${PTHREADS_EXCEPTION_SCHEME}2
			pthread
			libpthread.a libpthread.dll.a libpthread.la libpthreadGC2.a
	)
ELSEIF(MINGW)
	SET(names
			pthreadG${PTHREADS_EXCEPTION_SCHEME}2
			pthread
			libpthread.a libpthread.dll.a libpthread.la libpthreadGC2.a
	)
ELSE(MSVC) # Unix / Cygwin / Apple / Etc.
	SET(names pthread)
ENDIF(MSVC)

FIND_LIBRARY(PTHREADS_LIBRARY NAMES ${names}
	DOC "The Portable Threads Library"
	PATHS
	${CMAKE_SOURCE_DIR}/lib
	/usr/lib
	/usr/local/lib
	/lib
	/lib64
	/usr/lib64
	/usr/local/lib64
	$ENV{PTHREAD_LIBRARY_PATH}
	${PTHREADS_ROOT}/lib/${MSVC_C_ARCHITECTURE_ID}
	${PTHREADS_ROOT}/lib
	/usr/i686-pc-mingw32/sys-root/mingw/lib/
	/usr/i586-mingw32msvc/sys-root/mingw/lib/
	/usr/i586-mingw32msvc/lib/
	/usr/i686-pc-mingw32/lib/
	C:/MinGW/lib/
	/mingw/lib
	)

IF(PTHREADS_LIBRARY)
message(STATUS "Found PTHREADS LIBRARY: ${PTHREADS_LIBRARY} (PTHREADS Exception Scheme: ${PTHREADS_EXCEPTION_SCHEME})")
ELSE()
message(FATAL_ERROR "Could not find PTHREADS LIBRARY. See README.PLATFORMS for more information.")
ENDIF(PTHREADS_LIBRARY)

# INCLUDE(FindPackageHandleStandardArgs)
# FIND_PACKAGE_HANDLE_STANDARD_ARGS(Pthreads DEFAULT_MSG
	# PTHREADS_LIBRARY PTHREADS_INCLUDE_DIR)

IF(PTHREADS_INCLUDE_DIR AND PTHREADS_LIBRARY)
	SET(PTHREADS_DEFINITIONS -DHAVE_PTHREAD_H)
	SET(PTHREADS_INCLUDE_DIRS ${PTHREADS_INCLUDE_DIR})
	SET(PTHREADS_LIBRARIES	  ${PTHREADS_LIBRARY})
ENDIF(PTHREADS_INCLUDE_DIR AND PTHREADS_LIBRARY)

MARK_AS_ADVANCED(PTHREADS_INCLUDE_DIR)
MARK_AS_ADVANCED(PTHREADS_LIBRARY)