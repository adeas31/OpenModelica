cmake_minimum_required(VERSION 3.14)

file(GLOB OMC_SIMRT_UTIL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/util/*.c)
file(GLOB OMC_SIMRT_UTIL_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/util/*.h)

file(GLOB OMC_SIMRT_META_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/meta/*.c)
file(GLOB OMC_SIMRT_META_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/meta/*.h)

file(GLOB OMC_SIMRT_GC_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/gc/*.c)
file(GLOB OMC_SIMRT_GC_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/gc/*.h)

file(GLOB OMC_SIMRT_FMI_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/fmi/*.c)
file(GLOB OMC_SIMRT_FMI_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/fmi/*.h)



# ######################################################################################################################
# Library: omcmemory
## This tiny library provides the memory related functionality of OM (garbage collection and memory_pool).
## The reason it is separated is because its functionality is clearly defined and should not be part of
## a bunch of other libraries. For example there is no need to link to OpenModelicaRuntimeC just to get GC
## functionality in Compiler/runtime.
add_library(omcmemory STATIC)
add_library(omc::simrt::memory ALIAS omcmemory)

target_sources(omcmemory PRIVATE ${OMC_SIMRT_GC_SOURCES})
target_link_libraries(omcmemory PUBLIC omc::3rd::omcgc)
target_include_directories(omcmemory PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


# ######################################################################################################################
# Library: OpenModelicaRuntimeC
add_library(OpenModelicaRuntimeC STATIC)
add_library(omc::simrt::runtime ALIAS OpenModelicaRuntimeC)

target_sources(OpenModelicaRuntimeC PRIVATE ${OMC_SIMRT_UTIL_SOURCES} ${OMC_SIMRT_META_SOURCES})
target_link_libraries(OpenModelicaRuntimeC PUBLIC omc::simrt::memory)

if(WIN32)
  target_link_libraries(OpenModelicaRuntimeC PUBLIC dbghelp)
  target_link_libraries(OpenModelicaRuntimeC PUBLIC regex)
endif(WIN32)


install(TARGETS OpenModelicaRuntimeC)

# ######################################################################################################################
# Library: OpenModelicaFMIRuntimeC
add_library(OpenModelicaFMIRuntimeC STATIC)
add_library(omc::simrt::fmiruntime ALIAS OpenModelicaFMIRuntimeC)

target_sources(OpenModelicaFMIRuntimeC PRIVATE ${OMC_SIMRT_FMI_SOURCES})

target_link_libraries(OpenModelicaFMIRuntimeC PUBLIC omc::3rd::fmilib::static)

install(TARGETS OpenModelicaFMIRuntimeC)


# Quick and INCOMPLETE generation of RuntimeSources.mo
set(DGESV_FILES \"\")
set(LS_FILES \"\")
set(MIXED_FILES \"\")
set(NLS_FILESCMINPACK_FILES \"\")
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/RuntimeSources.mo.cmake ${CMAKE_CURRENT_SOURCE_DIR}/RuntimeSources.mo)
