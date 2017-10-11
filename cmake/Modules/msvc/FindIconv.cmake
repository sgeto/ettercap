# ==============================================================================
# This is a modified version of FindIconv.cmake for the ettercap project.
# I'm not sure who the original author of this module is. I took it from this
# repo:
#
# https://github.com/percolator/percolator
#
# If you must know who owns the copyright on it, you might want to start there.
#
# Apart from this notice, this module "enjoys" the following modifications:
#
# - users may be able to use the environment variable ICONV_ROOT to point
#   cmake to the *root* of their iconv installation.
#   Alternatively, ICONV_ROOT may also be set from cmake command line or GUI
#   (-DICONV_ROOT=/path/to/iconv)
#
# - added some additional status/error messages
#
# - replaced the C++ test with C equivalent
#
# Send suggestion, patches, gifts and praises to the ettercap developers.
# ==============================================================================

# - Try to find Iconv
# Once done this will define
# 
#  ICONV_FOUND - system has Iconv 
#  ICONV_INCLUDE_DIR - the Iconv include directory 
#  ICONV_LIBRARIES - Link these to use Iconv 
#  ICONV_SECOND_ARGUMENT_IS_CONST - the second argument for iconv() is const
# 
include(CheckCSourceCompiles)

IF (ICONV_INCLUDE_DIR AND ICONV_LIBRARIES)
  # Already in cache, be silent
  SET(ICONV_FOUND TRUE)
  SET(HAVE_ICONV TRUE)
ENDIF (ICONV_INCLUDE_DIR AND ICONV_LIBRARIES)

# Search the ICONV_ROOT environment variable first.
# set(ICONV_SEARCH_DIR ${ICONV_ROOT_DIR} $ENV{ICONV_INSTALL_DIR} $ENV{ICONV_ROOT})

if(ICONV_ROOT)
  set(ICONV_ROOT PATHS ${ICONV_ROOT} NO_DEFAULT_PATH)
else()
  set(ICONV_ROOT $ENV{ICONV_ROOT})
endif(ICONV_ROOT)

FIND_PATH(ICONV_INCLUDE_DIR iconv.h
  HINTS
  ${ICONV_INCLUDE_DIR}
  ${ICONV_ROOT}/include
  )

IF(ICONV_INCLUDE_DIR)
message(STATUS "Found iconv.h: ${ICONV_INCLUDE_DIR}")
ELSE()
message(FATAL_ERROR "Could not find iconv.h. See README.PLATFORMS for more information.")
ENDIF(ICONV_INCLUDE_DIR)

FIND_LIBRARY(ICONV_LIBRARIES NAMES iconv libiconv libiconv-2 c
  HINTS
  ${ICONV_LIBRARY}
  ${ICONV_ROOT}/lib
  )

IF(ICONV_LIBRARIES)
message(STATUS "Found ICONV LIBRARY: ${ICONV_LIBRARIES}")
ELSE()
message(FATAL_ERROR "Could not find ICONV LIBRARY. See README.PLATFORMS for more information.")
ENDIF(ICONV_LIBRARIES)

IF(ICONV_INCLUDE_DIR AND ICONV_LIBRARIES) 
  SET(ICONV_FOUND TRUE)
  SET(HAVE_ICONV TRUE)
ENDIF(ICONV_INCLUDE_DIR AND ICONV_LIBRARIES) 

set(CMAKE_REQUIRED_INCLUDES ${ICONV_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${ICONV_LIBRARIES})
IF(ICONV_FOUND)
  check_c_source_compiles("
  #include <iconv.h>
  int main(){
    iconv_t conv = 0;
    const char* in = 0;
    size_t ilen = 0;
    char* out = 0;
    size_t olen = 0;
    iconv(conv, &in, &ilen, &out, &olen);
    return 0;
  }
" ICONV_SECOND_ARGUMENT_IS_CONST )
ENDIF(ICONV_FOUND)
set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_REQUIRED_LIBRARIES)

MARK_AS_ADVANCED(
  ICONV_INCLUDE_DIR
  ICONV_LIBRARIES
  ICONV_SECOND_ARGUMENT_IS_CONST
)
