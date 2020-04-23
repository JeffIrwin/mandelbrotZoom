![](https://github.com/JeffIrwin/mandelbrotZoom/workflows/CI/badge.svg)

# mandelbrotZoom
Animate a zoom into the Mandelbrot set, in Fortran!

## Prerequisites
- [gfortran](http://www.mingw.org/) (other Fortran compilers may work)
- [ffmpeg](https://www.ffmpeg.org/download.html)
- Optional:  [GIMP](https://www.gimp.org/downloads/) to view images of individual frames in PPM format

## Download
`git clone https://github.com/JeffIrwin/mandelbrotZoom`

`cd mandelbrotZoom`

## Build
Use CMake, or run the provided CMake wrapper script:

    ./build.sh

## Run
`./build/fractal.exe < inputs/example-0.txt`

## Combine frames into movie
`ffmpeg.exe -i frames/example-0_%d.ppm -c:v libx264 -pix_fmt yuv420p example-movie.mp4`

## Finished product
https://www.youtube.com/watch?v=a4WoTi00l24
