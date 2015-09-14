@ECHO OFF
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

SET PATH_TO_BIN=mapnik-gyp\build\Release

CALL mapnik-gyp\benchmark-2.bat %PATH_TO_BIN%\test_proj_transform1.exe 10 100
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL mapnik-gyp\benchmark-2.bat %PATH_TO_BIN%\test_expression_parse.exe 10 100
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL mapnik-gyp\benchmark-2.bat %PATH_TO_BIN%\test_face_ptr_creation.exe 10 100
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL mapnik-gyp\benchmark-2.bat %PATH_TO_BIN%\test_font_registration.exe 10 100
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL mapnik-gyp\benchmark-2.bat %PATH_TO_BIN%\test_offset_converter.exe 10 100
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR


ECHO text rendering...
%PATH_TO_BIN%\test_rendering.exe ^
--name "text rendering" ^
--map benchmark\data\roads.xml ^
--extent 1477001.12245,6890242.37746,1480004.49012,6892244.62256 ^
--width 600 ^
--height 600 ^
--iterations 20 ^
--threads 10
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO gdal tiff rendering...
%PATH_TO_BIN%\test_rendering.exe ^
--name "gdal tiff rendering" ^
--map benchmark/data/gdal-wgs.xml ^
--extent -180.0,-120.0,180.0,120.0 ^
--width 600 ^
--height 600 ^
--iterations 20 ^
--threads 10
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO raster tiff rendering...
%PATH_TO_BIN%\test_rendering.exe ^
--name "raster tiff rendering" ^
--map benchmark/data/raster-wgs.xml ^
--extent -180.0,-120.0,180.0,120.0 ^
--width 600 ^
--height 600 ^
--iterations 20 ^
--threads 10
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO test_quad_tree iterations^:10000 ...
%PATH_TO_BIN%\test_quad_tree ^
  --iterations 10000 ^
  --threads 1
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO test_quad_tree iterations^:1000 threads^:10 ...
%PATH_TO_BIN%\test_quad_tree ^
  --iterations 1000 ^
  --threads 10
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

%PATH_TO_BIN%\test_rendering.exe --name polygon_rendering_clip.xml --map benchmark\data\polygon_rendering_clip.xml
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
%PATH_TO_BIN%\test_rendering.exe --name polygon_rendering_no_clip.xml --map benchmark\data\polygon_rendering_no_clip.xml
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
%PATH_TO_BIN%\test_rendering.exe --name roads.xml --map benchmark\data\roads.xml
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR



::https://github.com/mapnik/mapnik/blob/master/benchmark/run



IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0
IF %ERRORLEVEL% NEQ 0 GOTO ERROR



GOTO DONE

:ERROR
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %ERRORLEVEL%
SET EL=%ERRORLEVEL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

EXIT /b %EL%
