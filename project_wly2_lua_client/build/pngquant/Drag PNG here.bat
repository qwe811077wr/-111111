@echo off

set path=%~d0%~p0

:start

"%path%pngquant.exe" -f --ext .png --quality 10-90 --speed 1 %1

shift
if NOT x%1==x goto start
