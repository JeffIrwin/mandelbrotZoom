# mandelbrotZoom
Animate a zoom into the Mandelbrot set, in Fortran!

## Prerequisites
- gfortran (other Fortran compilers may work)
- ffmpeg

## Build
`.\compile.cmd`

## Run
`.\fractal.exe < example-input.txt`

## Combine frames into movie
`ffmpeg.exe -i frames\example_%d.ppm -c:v libx264 -pix_fmt yuv420p example-movie.mp4`
