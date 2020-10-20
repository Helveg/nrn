# ~~~
# This allows h.nrnversion(6) to print only the configuration differences
# analogously to what happens with an autotools build.
# The <optionname>_DEFAULT values should only be changed in this file
# and not on the command line.
# ~~~
set(NRN_ENABLE_SHARED_DEFAULT ON)
set(NRN_ENABLE_BINARY_SPECIAL_DEFAULT OFF)
set(NRN_ENABLE_INTERVIEWS_DEFAULT ON)
set(NRN_ENABLE_LEGACY_FR_DEFAULT ON)
set(NRN_ENABLE_MECH_DLL_STYLE_DEFAULT ON)
set(NRN_ENABLE_DISCRETE_EVENT_OBSERVER_DEFAULT ON)
set(NRN_ENABLE_PYTHON_DEFAULT ON)
set(NRN_ENABLE_THREADS_DEFAULT ON)
set(NRN_ENABLE_MPI_DEFAULT ON)
set(NRN_ENABLE_MEMACS_DEFAULT ON)
set(NRN_ENABLE_RX3D_DEFAULT ON)
set(NRN_ENABLE_CORENEURON_DEFAULT OFF)
set(NRN_ENABLE_BACKTRACE_DEFAULT OFF)
set(NRN_ENABLE_TESTS_DEFAULT OFF)
set(NRN_ENABLE_MODULE_INSTALL_DEFAULT ON)
set(NRN_ENABLE_PYTHON_DYNAMIC_DEFAULT OFF)
set(NRN_ENABLE_MPI_DYNAMIC_DEFAULT OFF)
set(NRN_ENABLE_MOD_COMPATIBILITY_DEFAULT OFF)
set(NRN_ENABLE_REL_RPATH_DEFAULT OFF)

# on cray cross compiling environment, use internal readline
if(IS_DIRECTORY "/opt/cray")
  set(NRN_ENABLE_INTERNAL_READLINE_DEFAULT ON)
else()
  set(NRN_ENABLE_INTERNAL_READLINE_DEFAULT OFF)
endif()
# Some distributions may set the prefix. To avoid errors, unset it
set(NRN_MODULE_INSTALL_OPTIONS_DEFAULT "--prefix= --home=${CMAKE_INSTALL_PREFIX}")
set(NRN_PYTHON_DYNAMIC_DEFAULT "")
set(NRN_MPI_DYNAMIC_DEFAULT "")
set(NRN_RX3D_OPT_LEVEL_DEFAULT "0")

# Some CMAKE variables we would like to see, if they differ from the following.
set(CMAKE_BUILD_TYPE_DEFAULT RelWithDebInfo)
set(CMAKE_INSTALL_PREFIX_DEFAULT "/usr/local")
set(CMAKE_C_COMPILER_DEFAULT "gcc")
set(PYTHON_EXECUTABLE_DEFAULT "")
set(IV_LIB_DEFAULT "")

set(NRN_OPTION_NAME_LIST
    NRN_ENABLE_SHARED
    NRN_ENABLE_BINARY_SPECIAL
    NRN_ENABLE_INTERVIEWS
    NRN_ENABLE_LEGACY_FR
    NRN_ENABLE_MECH_DLL_STYLE
    NRN_ENABLE_DISCRETE_EVENT_OBSERVER
    NRN_ENABLE_PYTHON
    NRN_ENABLE_THREADS
    NRN_ENABLE_MPI
    NRN_ENABLE_MEMACS
    NRN_ENABLE_RX3D
    NRN_ENABLE_CORENEURON
    NRN_ENABLE_TESTS
    NRN_ENABLE_MODULE_INSTALL
    NRN_ENABLE_PYTHON_DYNAMIC
    NRN_MODULE_INSTALL_OPTIONS
    NRN_PYTHON_DYNAMIC
    NRN_MPI_DYNAMIC
    NRN_RX3D_OPT_LEVEL
    CMAKE_BUILD_TYPE
    CMAKE_INSTALL_PREFIX
    CMAKE_C_COMPILER
    PYTHON_EXECUTABLE
    IV_LIB)
