
cmake_minimum_required(VERSION 3.7)

set(PROJECT fractal)

if (LINUX)
	set(CMAKE_Fortran_FLAGS "-Wall -Wextra -fopenmp")
	set(CMAKE_Fortran_FLAGS_DEBUG "-pedantic -fbounds-check -fbacktrace")
	set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
elseif (APPLE)
else()
	# Windows
	set(CMAKE_Fortran_FLAGS "-Wall -Wextra -fopenmp")
	set(CMAKE_Fortran_FLAGS_DEBUG "-pedantic -fbounds-check -fbacktrace")
	set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
endif()

message("PATH = $ENV{PATH}")

#set(CMAKE_Fortran_COMPILER "/c/Program Files/mingw-w64/x86_64-8.1.0-win32-seh-rt_v6-rev0/mingw64/bin/gfortran")
set(CMAKE_Fortran_COMPILER "gfortran")

project(${PROJECT} Fortran)

#set(SUBMODULE_DIR submodules)

#set(JSON_DIR ${SUBMODULE_DIR}/json/single_include/nlohmann)

#include_directories(${JSON_DIR})

add_executable(${PROJECT} fractal.f90)

