# This file will be regenerated by `mulle-sourcetree-to-cmake` via
# `mulle-sde reflect` and any edits will be lost.
#
# This file will be included by cmake/share/Files.cmake
#
# Disable generation of this file with:
#
# mulle-sde environment set MULLE_SOURCETREE_TO_CMAKE_DEPENDENCIES_FILE DISABLE
#
if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# Generated from sourcetree: 145E1BC1-501C-441A-8463-F50E4E2B6512;MulleFoundation;no-singlephase;
# Disable with : `mulle-sourcetree mark MulleFoundation no-link`
# Disable for this platform: `mulle-sourcetree mark MulleFoundation no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleFoundation no-cmake-sdk-<name>`
#
if( COLLECT_ALL_LOAD_DEPENDENCY_LIBRARIES_AS_NAMES)
   list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES "MulleFoundation")
else()
   if( NOT MULLE_FOUNDATION_LIBRARY)
      find_library( MULLE_FOUNDATION_LIBRARY NAMES
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
         MulleFoundation
         NO_CMAKE_SYSTEM_PATH NO_SYSTEM_ENVIRONMENT_PATH
      )
      if( NOT MULLE_FOUNDATION_LIBRARY AND NOT DEPENDENCY_IGNORE_SYSTEM_LIBARIES)
         find_library( MULLE_FOUNDATION_LIBRARY NAMES
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
            MulleFoundation
         )
      endif()
      message( STATUS "MULLE_FOUNDATION_LIBRARY is ${MULLE_FOUNDATION_LIBRARY}")
      #
      # The order looks ascending, but due to the way this file is read
      # it ends up being descending, which is what we need.
      #
      if( MULLE_FOUNDATION_LIBRARY)
         #
         # Add MULLE_FOUNDATION_LIBRARY to ALL_LOAD_DEPENDENCY_LIBRARIES list.
         # Disable with: `mulle-sourcetree mark MulleFoundation no-cmake-add`
         #
         list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES ${MULLE_FOUNDATION_LIBRARY})
         #
         # Inherit information from dependency.
         # Encompasses: no-cmake-searchpath,no-cmake-dependency,no-cmake-loader
         # Disable with: `mulle-sourcetree mark MulleFoundation no-cmake-inherit`
         #
         # temporarily expand CMAKE_MODULE_PATH
         get_filename_component( _TMP_MULLE_FOUNDATION_ROOT "${MULLE_FOUNDATION_LIBRARY}" DIRECTORY)
         get_filename_component( _TMP_MULLE_FOUNDATION_ROOT "${_TMP_MULLE_FOUNDATION_ROOT}" DIRECTORY)
         #
         #
         # Search for "Definitions.cmake" and "DependenciesAndLibraries.cmake" to include.
         # Disable with: `mulle-sourcetree mark MulleFoundation no-cmake-dependency`
         #
         foreach( _TMP_MULLE_FOUNDATION_NAME "MulleFoundation")
            set( _TMP_MULLE_FOUNDATION_DIR "${_TMP_MULLE_FOUNDATION_ROOT}/include/${_TMP_MULLE_FOUNDATION_NAME}/cmake")
            # use explicit path to avoid "surprises"
            if( IS_DIRECTORY "${_TMP_MULLE_FOUNDATION_DIR}")
               list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_FOUNDATION_DIR}")
               #
               include( "${_TMP_MULLE_FOUNDATION_DIR}/DependenciesAndLibraries.cmake" OPTIONAL)
               #
               list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_FOUNDATION_DIR}")
               #
               unset( MULLE_FOUNDATION_DEFINITIONS)
               include( "${_TMP_MULLE_FOUNDATION_DIR}/Definitions.cmake" OPTIONAL)
               list( APPEND INHERITED_DEFINITIONS ${MULLE_FOUNDATION_DEFINITIONS})
               break()
            else()
               message( STATUS "${_TMP_MULLE_FOUNDATION_DIR} not found")
            endif()
         endforeach()
         #
         # Search for "MulleObjCLoader+<name>.h" in include directory.
         # Disable with: `mulle-sourcetree mark MulleFoundation no-cmake-loader`
         #
         if( NOT NO_INHERIT_OBJC_LOADERS)
            foreach( _TMP_MULLE_FOUNDATION_NAME "MulleFoundation")
               set( _TMP_MULLE_FOUNDATION_FILE "${_TMP_MULLE_FOUNDATION_ROOT}/include/${_TMP_MULLE_FOUNDATION_NAME}/MulleObjCLoader+${_TMP_MULLE_FOUNDATION_NAME}.h")
               if( EXISTS "${_TMP_MULLE_FOUNDATION_FILE}")
                  list( APPEND INHERITED_OBJC_LOADERS ${_TMP_MULLE_FOUNDATION_FILE})
                  break()
               endif()
            endforeach()
         endif()
      else()
         # Disable with: `mulle-sourcetree mark MulleFoundation no-require-link`
         message( SEND_ERROR "MULLE_FOUNDATION_LIBRARY was not found")
      endif()
   endif()
endif()


#
# Generated from sourcetree: C0E0634B-1CA4-43E3-BEFD-0094542DB54D;MulleObjCHTTPFoundation;no-singlephase;
# Disable with : `mulle-sourcetree mark MulleObjCHTTPFoundation no-link`
# Disable for this platform: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-sdk-<name>`
#
if( COLLECT_ALL_LOAD_DEPENDENCY_LIBRARIES_AS_NAMES)
   list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES "MulleObjCHTTPFoundation")
else()
   if( NOT MULLE_OBJC_HTTP_FOUNDATION_LIBRARY)
      find_library( MULLE_OBJC_HTTP_FOUNDATION_LIBRARY NAMES
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCHTTPFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCHTTPFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
         MulleObjCHTTPFoundation
         NO_CMAKE_SYSTEM_PATH NO_SYSTEM_ENVIRONMENT_PATH
      )
      if( NOT MULLE_OBJC_HTTP_FOUNDATION_LIBRARY AND NOT DEPENDENCY_IGNORE_SYSTEM_LIBARIES)
         find_library( MULLE_OBJC_HTTP_FOUNDATION_LIBRARY NAMES
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCHTTPFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCHTTPFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
            MulleObjCHTTPFoundation
         )
      endif()
      message( STATUS "MULLE_OBJC_HTTP_FOUNDATION_LIBRARY is ${MULLE_OBJC_HTTP_FOUNDATION_LIBRARY}")
      #
      # The order looks ascending, but due to the way this file is read
      # it ends up being descending, which is what we need.
      #
      if( MULLE_OBJC_HTTP_FOUNDATION_LIBRARY)
         #
         # Add MULLE_OBJC_HTTP_FOUNDATION_LIBRARY to ALL_LOAD_DEPENDENCY_LIBRARIES list.
         # Disable with: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-add`
         #
         list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES ${MULLE_OBJC_HTTP_FOUNDATION_LIBRARY})
         #
         # Inherit information from dependency.
         # Encompasses: no-cmake-searchpath,no-cmake-dependency,no-cmake-loader
         # Disable with: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-inherit`
         #
         # temporarily expand CMAKE_MODULE_PATH
         get_filename_component( _TMP_MULLE_OBJC_HTTP_FOUNDATION_ROOT "${MULLE_OBJC_HTTP_FOUNDATION_LIBRARY}" DIRECTORY)
         get_filename_component( _TMP_MULLE_OBJC_HTTP_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_ROOT}" DIRECTORY)
         #
         #
         # Search for "Definitions.cmake" and "DependenciesAndLibraries.cmake" to include.
         # Disable with: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-dependency`
         #
         foreach( _TMP_MULLE_OBJC_HTTP_FOUNDATION_NAME "MulleObjCHTTPFoundation")
            set( _TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_HTTP_FOUNDATION_NAME}/cmake")
            # use explicit path to avoid "surprises"
            if( IS_DIRECTORY "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR}")
               list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR}")
               #
               include( "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR}/DependenciesAndLibraries.cmake" OPTIONAL)
               #
               list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR}")
               #
               unset( MULLE_OBJC_HTTP_FOUNDATION_DEFINITIONS)
               include( "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR}/Definitions.cmake" OPTIONAL)
               list( APPEND INHERITED_DEFINITIONS ${MULLE_OBJC_HTTP_FOUNDATION_DEFINITIONS})
               break()
            else()
               message( STATUS "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_DIR} not found")
            endif()
         endforeach()
         #
         # Search for "MulleObjCLoader+<name>.h" in include directory.
         # Disable with: `mulle-sourcetree mark MulleObjCHTTPFoundation no-cmake-loader`
         #
         if( NOT NO_INHERIT_OBJC_LOADERS)
            foreach( _TMP_MULLE_OBJC_HTTP_FOUNDATION_NAME "MulleObjCHTTPFoundation")
               set( _TMP_MULLE_OBJC_HTTP_FOUNDATION_FILE "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_HTTP_FOUNDATION_NAME}/MulleObjCLoader+${_TMP_MULLE_OBJC_HTTP_FOUNDATION_NAME}.h")
               if( EXISTS "${_TMP_MULLE_OBJC_HTTP_FOUNDATION_FILE}")
                  list( APPEND INHERITED_OBJC_LOADERS ${_TMP_MULLE_OBJC_HTTP_FOUNDATION_FILE})
                  break()
               endif()
            endforeach()
         endif()
      else()
         # Disable with: `mulle-sourcetree mark MulleObjCHTTPFoundation no-require-link`
         message( SEND_ERROR "MULLE_OBJC_HTTP_FOUNDATION_LIBRARY was not found")
      endif()
   endif()
endif()


#
# Generated from sourcetree: C8D51D49-80CF-406E-A07D-0E339B282AB2;MulleObjCInetOSFoundation;no-singlephase;
# Disable with : `mulle-sourcetree mark MulleObjCInetOSFoundation no-link`
# Disable for this platform: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-sdk-<name>`
#
if( COLLECT_ALL_LOAD_DEPENDENCY_LIBRARIES_AS_NAMES)
   list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES "MulleObjCInetOSFoundation")
else()
   if( NOT MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY)
      find_library( MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY NAMES
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCInetOSFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCInetOSFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
         MulleObjCInetOSFoundation
         NO_CMAKE_SYSTEM_PATH NO_SYSTEM_ENVIRONMENT_PATH
      )
      if( NOT MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY AND NOT DEPENDENCY_IGNORE_SYSTEM_LIBARIES)
         find_library( MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY NAMES
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCInetOSFoundation${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
            ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjCInetOSFoundation${CMAKE_STATIC_LIBRARY_SUFFIX}
            MulleObjCInetOSFoundation
         )
      endif()
      message( STATUS "MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY is ${MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY}")
      #
      # The order looks ascending, but due to the way this file is read
      # it ends up being descending, which is what we need.
      #
      if( MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY)
         #
         # Add MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY to ALL_LOAD_DEPENDENCY_LIBRARIES list.
         # Disable with: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-add`
         #
         list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES ${MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY})
         #
         # Inherit information from dependency.
         # Encompasses: no-cmake-searchpath,no-cmake-dependency,no-cmake-loader
         # Disable with: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-inherit`
         #
         # temporarily expand CMAKE_MODULE_PATH
         get_filename_component( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_ROOT "${MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY}" DIRECTORY)
         get_filename_component( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_ROOT}" DIRECTORY)
         #
         #
         # Search for "Definitions.cmake" and "DependenciesAndLibraries.cmake" to include.
         # Disable with: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-dependency`
         #
         foreach( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_NAME "MulleObjCInetOSFoundation")
            set( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_NAME}/cmake")
            # use explicit path to avoid "surprises"
            if( IS_DIRECTORY "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR}")
               list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR}")
               #
               include( "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR}/DependenciesAndLibraries.cmake" OPTIONAL)
               #
               list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR}")
               #
               unset( MULLE_OBJC_INET_OS_FOUNDATION_DEFINITIONS)
               include( "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR}/Definitions.cmake" OPTIONAL)
               list( APPEND INHERITED_DEFINITIONS ${MULLE_OBJC_INET_OS_FOUNDATION_DEFINITIONS})
               break()
            else()
               message( STATUS "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_DIR} not found")
            endif()
         endforeach()
         #
         # Search for "MulleObjCLoader+<name>.h" in include directory.
         # Disable with: `mulle-sourcetree mark MulleObjCInetOSFoundation no-cmake-loader`
         #
         if( NOT NO_INHERIT_OBJC_LOADERS)
            foreach( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_NAME "MulleObjCInetOSFoundation")
               set( _TMP_MULLE_OBJC_INET_OS_FOUNDATION_FILE "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_NAME}/MulleObjCLoader+${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_NAME}.h")
               if( EXISTS "${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_FILE}")
                  list( APPEND INHERITED_OBJC_LOADERS ${_TMP_MULLE_OBJC_INET_OS_FOUNDATION_FILE})
                  break()
               endif()
            endforeach()
         endif()
      else()
         # Disable with: `mulle-sourcetree mark MulleObjCInetOSFoundation no-require-link`
         message( SEND_ERROR "MULLE_OBJC_INET_OS_FOUNDATION_LIBRARY was not found")
      endif()
   endif()
endif()
