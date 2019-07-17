# verify that NRNMPI_DYNAMIC is valid and determine
# an include directory for each mpi package
# building libnrnmpi_<mpipkg>.so
# Depending on the mpis used NRNMPI_INCLUDE_<mpipkg> will be defined.

# here is an idiom to print all the MPI variables
macro (myvarnames_beginning_with pre)
  get_cmake_property(_variableNames VARIABLES)
  list (SORT _variableNames)
  foreach (_variableName ${_variableNames})
    if (_variableName MATCHES "^${pre}")
      message(NOTICE " ${_variableName} ${${_variableName}}")
    endif()
  endforeach()
endmacro()

if (NOT ENABLE_MPI AND NOT NRNMPI_DYNAMIC MATCHES "NO")
  set(NRNMPI_DYNAMIC "NO")
endif()

if (NRNMPI_DYNAMIC MATCHES "NO")
  #do nothing
elseif (NRNMPI_DYNAMIC MATCHES "YES")
  #use the default mpi already determined
  #myvarnames_beginning_with("[Mm][Pp][Ii]")
  set(NRNMPI_DYNAMICLOAD 1)
else()
  message(FATAL_ERROR " NRNMPI_DYNAMIC for now only YES or NO")
endif()