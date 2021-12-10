module fmod

use pnmio

implicit none

double precision, parameter :: e = exp(1.d0)

integer, parameter :: debug = 2

!********

abstract interface

  double complex function function_template(z, c)
  double complex :: z, c
  end function function_template

end interface

!********

contains

!=======================================================================

! h in [0, 360], s in [0, 1], v in [0, 1]

! rgb in [0, 255]

function hsv2rgb(hsv)

double precision :: rgb(3), hp, c, x, m, hsv(3)

integer :: hsv2rgb(3)

c = hsv(2) * hsv(3)
hp = hsv(1) / 60.d0
x = c * (1.d0 - abs(mod(hp, 2.d0) - 1.d0))

if      (0.d0 <= hp .and. hp < 1.d0) then
  rgb = [c, x, 0.d0]
else if (1.d0 <= hp .and. hp < 2.d0) then
  rgb = [x, c, 0.d0]
else if (2.d0 <= hp .and. hp < 3.d0) then
  rgb = [0.d0, c, x]
else if (3.d0 <= hp .and. hp < 4.d0) then
  rgb = [0.d0, x, c]
else if (4.d0 <= hp .and. hp < 5.d0) then
  rgb = [x, 0.d0, c]
else if (5.d0 <= hp .and. hp <= 6.d0) then
  rgb = [c, 0.d0, x]
else
  write(*,*)
  write(*,*) 'ERROR in hsv2rgb'
  write(*,*) 'Hue outside of range [0, 360]'
  write(*,*) 'Hue = ', hsv(1)
  write(*,*)
  stop
end if

m = hsv(3) - c
rgb = rgb + m

hsv2rgb = min(255, floor(rgb * 256.d0))

if (debug >= 3) print *, ''
if (debug >= 3) print *, 'rgb = ', rgb
if (debug >= 3) print *, 'hsv2rgb = ', hsv2rgb

end function hsv2rgb

!=======================================================================

double complex function fmandelbrot(z, c)

double complex :: z, c

fmandelbrot = z ** 2 + c

end function fmandelbrot

!=======================================================================

double complex function fship(z, c)

! Burning ship

double complex :: z, c

fship = complex(abs(realpart(z)), abs(imagpart(z))) ** 2 + c

end function fship

!=======================================================================

integer function nitrescape(c, maxitr, escape, f)

double precision, intent(in) :: escape

double complex, intent(in) :: c
double complex, external :: f
!procedure(function_template), pointer :: f
double complex :: z

integer, intent(in) :: maxitr

z = c
nitrescape = 0
do while (nitrescape < maxitr .and. abs(z) < escape)
  nitrescape = nitrescape + 1
  z = f(z, c)
end do

end function nitrescape

!=======================================================================

subroutine testpbm

!integer, allocatable :: b(:,:)
character, allocatable :: b(:,:)
integer :: ix, iy, io

allocate(b(900, 360))

do ix = 1, 300
  do iy = 1, 360
    b(3 * ix - 2: 3 * ix, iy) = achar(hsv2rgb([dble(iy), 1.d0, 1.d0]))
  end do
end do

io = writepnm(6, b, 'test')
if (io /= 0) stop

end subroutine testpbm

!=======================================================================

end module fmod

!=======================================================================

program fractal

use fmod

implicit none

character :: fname*256, ct*6
character(len = :), allocatable :: fdir

double precision :: xmin, xmax, ymin, ymax, dx, dy, escape, h
double precision :: xmin0, ymin0, xmax0, ymax0, xc, yc, zoom, znt
double precision :: dxmax, dxmin, dymax, dymin, hm
double precision, allocatable :: x(:), y(:)

double complex :: c
!double complex, external :: f
procedure(function_template), pointer :: fiterator

integer :: nx, ny, maxitr, i, ix, iy, nitr, t0, t, crate, frm, nt, it, io, &
    ifractal
!integer, allocatable :: b(:,:)
character, allocatable :: b(:,:)

logical :: fexist

!call testpbm
!stop

call system_clock(t0)
call system_clock(count_rate = crate)

write(*,*)
write(*,*) 'Enter file format (1 - 3):'
read(*,*) frm

write(*,*)
write(*,*) 'Enter escape radius:'
read(*,*) escape

write(*,*)
write(*,*) 'Enter maximum number of iterations:'
read(*,*) maxitr

write(*,*)
write(*,*) 'Enter initial min/max x bounds:'
read(*,*) xmin0, xmax0

write(*,*)
write(*,*) 'Enter initial min/max y bounds:'
read(*,*) ymin0, ymax0

write(*,*)
write(*,*) 'Enter zoom center x/y coordinates:'
read(*,*) xc, yc

write(*,*)
write(*,*) 'Enter final zoom magnification:'
read(*,*) zoom

write(*,*)
write(*,*) 'Enter number of frames:'
read(*,*) nt

write(*,*)
write(*,*) 'Enter number of x/y pixels:'
read(*,*) nx, ny

write(*,*)
write(*,*) 'Enter pre-modulo hue multiplier:'
read(*,*) hm

write(*,*)
write(*,*) 'Enter file name:'
read(*,*) fname

write(*,*)
write(*,*) 'Enter fractal iteration function (1 for Mandelbrot or' &
    //' 2 for burning ship):'
read(*,*) ifractal

write(*,*)
write(*,*) '====================================================='

write(*,*)
write(*,*) 'format             = ', frm
write(*,*) 'escape             = ', escape
write(*,*) 'maxitr             = ', maxitr
write(*,*) 'xbounds            = ', xmin0, xmax0
write(*,*) 'ybounds            = ', ymin0, ymax0
write(*,*) 'Zoom center        = ', xc, yc
write(*,*) 'Zoom magnification = ', zoom
write(*,*) 'Frames             = ', nt
write(*,*) 'Image size         = ', nx, ny
write(*,*) 'Hue multiplier     = ', hm
write(*,*) 'File name          = ', trim(fname)
write(*,*) 'Fractal iterator   = ', ifractal

write(*,*)
write(*,*) '====================================================='

allocate(x(nx))
allocate(y(ny))

if (frm == 1 .or. frm == 2) then
  allocate(b(nx, ny))
else
  allocate(b(3 * nx, ny))
end if

fdir = 'frames'

! TODO:  hide errors for all OSs
call system('mkdir "'//fdir//'"')

znt = zoom ** (1.d0 / dble(nt))

dxmax = xmax0 - xc
dxmin = xc - xmin0
dymax = ymax0 - yc
dymin = yc - ymin0

do it = 0, nt

  write(*, '(a, i0)') 'frame = ', it

  write(ct, '(i0)') it
  !print *, 'ct = ', ct

  xmax = xc + dxmax * znt ** (-it)
  xmin = xc - dxmin * znt ** (-it)
  ymax = yc + dymax * znt ** (-it)
  ymin = yc - dymin * znt ** (-it)

  dx = (xmax - xmin) / dble(nx - 1)
  dy = (ymax - ymin) / dble(ny - 1)

  if (debug >= 1) print *, 'dx, dy = ', dx, dy
  if (debug >= 2) print *, 'xmin, xmax = ', xmin, xmax
  if (debug >= 2) print *, 'ymin, ymax = ', ymin, ymax

  x = [(xmin + dble(i) * dx, i = 0, nx - 1)]
  y = [(ymin + dble(i) * dy, i = 0, ny - 1)]

  !! Works on Windows but not Ubuntu?  gfortran version diff?
  !if (ifractal == 1) then
  !  fiterator => fmandelbrot
  !else
  !  fiterator => fship
  !end if

!$OMP parallel shared(b, x, y, nx, ny, maxitr, escape, frm)
!$OMP do schedule(dynamic)
  do iy = 1, ny
    do ix = 1, nx

      c = complex(x(ix), y(iy))

      !nitr = nitrescape(c, maxitr, escape, fiterator)

      ! Avoid condition branches in big loops!
      if (ifractal == 1) then
        nitr = nitrescape(c, maxitr, escape, fmandelbrot)
      else
        nitr = nitrescape(c, maxitr, escape, fship)
      end if

      if (debug >= 3) print *, 'nitr = ', nitr

      if (frm == 1) then

        ! B & W
        if (nitr == maxitr) then
          !b(ix, iy) = 0
          b(ix, iy) = achar(0)
        else
          !b(ix, iy) = 1
          b(ix, iy) = achar(1)
        end if

      else if (frm == 2) then

        ! Grayscale
        !b(ix, iy) = mod(nitr, 256)
        b(ix, iy) = achar(mod(nitr, 256))

      else if (frm == 3) then

        ! RGB

        !! Red/black contour
        !b(ix, iy) = mod(nitr, 256), 0, 0

        ! HSV map
        if (nitr == maxitr) then
          !b(3 * ix - 2: 3 * ix, iy) = [0, 0, 0]
          b(3 * ix - 2: 3 * ix, iy) = achar([0, 0, 0])
        else

          !h = mod(180.d0 + 360.d0 * dble(nitr) / maxitr, 360.d0)
          h = 360.d0 * mod(hm * dble(nitr) / maxitr, 1.d0)
  
          !b(3 * ix - 2: 3 * ix, iy) = hsv2rgb([h, 1.d0, 1.d0])
          b(3 * ix - 2: 3 * ix, iy) = achar(hsv2rgb([h, 1.d0, 1.d0]))

        end if ! RGB color map style
      end if   ! frm
    end do     ! ix
  end do       ! iy

!$OMP end do
!$OMP end parallel

  io = writepnm(frm, b, fdir//'/'//trim(fname)//'_'//trim(ct))
  if (io /= 0) stop

end do         ! it

call system_clock(t)

write(*,*)
!print *, 't, t0, crate = ', t, t0, crate
write(*,*) 'Elapsed time = ', dble(t - t0) / dble(crate)
write(*,*)

end program fractal
