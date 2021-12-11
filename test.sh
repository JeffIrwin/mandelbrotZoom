#!/bin/bash

exebase=fractal
frames=( 2 10 )

inputs=./inputs/*.txt
outdir=./inputs/frames
expectedoutdir=./inputs/expected-output
outputext=ppm

source ./submodules/bat/test.sh

