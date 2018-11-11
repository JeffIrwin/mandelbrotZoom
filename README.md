# mandelbrotZoom
Animate a zoom into the Mandelbrot set, in Fortran!

## Prerequisites
- [gfortran](http://www.mingw.org/) (other Fortran compilers may work)
- [ffmpeg](https://www.ffmpeg.org/download.html)
- Optional:  [GIMP](https://www.gimp.org/downloads/) to view images of individual frames in PPM format

## Build
`.\compile.cmd`

## Run
`.\fractal.exe < example-input.txt`

## Combine frames into movie
`ffmpeg.exe -i frames\example_%d.ppm -c:v libx264 -pix_fmt yuv420p example-movie.mp4`
