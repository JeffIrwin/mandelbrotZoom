#!/bin/bash

gfortran -o fractal fractal.f90 -O3 -fopenmp
#gfortran -o fractal fractal.f90 -Wall -Wextra -pedantic -fbounds-check -fbacktrace -fopenmp

