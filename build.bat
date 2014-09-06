@echo off

::git clone https://chromium.googlesource.com/external/gyp.git
::CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86
::SET PATH=C:\Python27;%PATH%

::ddt %MAPNIK_SDK%
::IF ERRORLEVEL NEQ 0 GOTO ERROR
::ddt build\Release
::IF ERRORLEVEL NEQ 0 GOTO ERROR

if NOT EXIST gyp (
    CALL git clone https://chromium.googlesource.com/external/gyp.git gyp
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

:: run find command and bail on error
:: this ensures we have the unix find command on path
:: before trying to run gyp
find ../deps/clipper/src/ -name "*.cpp"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET MAPNIK_SDK=%CD%\mapnik-sdk
SET DEPSDIR=..\..

CALL gyp\gyp.bat mapnik.gyp --depth=. ^
 -Dincludes=%MAPNIK_SDK%/includes ^
 -Dlibs=%MAPNIK_SDK%/libs ^
 -f msvs -G msvs_version=2013 ^
 --generator-output=build ^
 --no-duplicate-basename-check
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST %MAPNIK_SDK% (
  mkdir %MAPNIK_SDK%
  mkdir %MAPNIK_SDK%\bin
  mkdir %MAPNIK_SDK%\includes
  mkdir %MAPNIK_SDK%\share
  mkdir %MAPNIK_SDK%\libs
  mkdir %MAPNIK_SDK%\libs\mapnik\input
  mkdir %MAPNIK_SDK%\libs\mapnik\fonts
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:: includes
xcopy /q %DEPSDIR%\harfbuzz-build\harfbuzz\hb-version.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb-shape-plan.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb-shape.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb-set.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb-ft.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\harfbuzz\src\hb-buffer.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-unicode.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-common.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-blob.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-font.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-face.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy  /q %DEPSDIR%\harfbuzz\src\hb-deprecated.h %MAPNIK_SDK%\includes\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\boost_1_56_0\boost %MAPNIK_SDK%\includes\boost /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\icu\include\unicode %MAPNIK_SDK%\includes\unicode /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\freetype\include %MAPNIK_SDK%\includes\freetype2 /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\libxml2\include %MAPNIK_SDK%\includes\libxml2 /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\zlib\zlib.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\zlib\zconf.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libpng\png.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libpng\pnglibconf.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libpng\pngconf.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\jpeg\jpeglib.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\jpeg\jconfig.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\jpeg\jmorecfg.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\webp\src\webp %MAPNIK_SDK%\includes\webp /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\proj\src\proj_api.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\tiff.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\tiffvers.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\tiffconf.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\tiffio.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\cairo-version.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-features.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-deprecated.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-svg.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-svg-surface-private.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-pdf.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-ft.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\cairo-ps.h %MAPNIK_SDK%\includes\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\protobuf\vsprojects\include %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: libs
xcopy /q %DEPSDIR%\harfbuzz-build\harfbuzz.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\freetype\freetype.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\icu\lib\icuuc.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\icu\lib\icuin.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\icu\bin\icuuc53.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\icu\bin\icudt53.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\icu\bin\icuin53.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a_dll.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\libtiff.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /i /d /s /q %DEPSDIR%\libtiff\libtiff\libtiff.lib %MAPNIK_SDK%\libs\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libtiff\libtiff\libtiff_i.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\zlib\zlib.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\proj\src\proj.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\webp\output\release-dynamic\x86\lib\libwebp_dll.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\webp\output\release-dynamic\x86\bin\libwebp.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libpng\projects\vstudio\Release\libpng16.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\libpng\projects\vstudio\Release\libpng16.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\jpeg\libjpeg.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\release\cairo-static.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\release\cairo.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\cairo\src\release\cairo.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\boost_1_56_0\stage\lib\* %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\protobuf\vsprojects\Release\libprotobuf-lite.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: data
xcopy /i /d /s /q %DEPSDIR%\proj\nad %MAPNIK_SDK%\share\proj /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\gdal\data %MAPNIK_SDK%\share\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: bin
xcopy /q %DEPSDIR%\protobuf\vsprojects\Release\protoc.exe %MAPNIK_SDK%\bin /Y
xcopy /q mapnik-config.bat %MAPNIK_SDK%\bin /Y

:: headers for plugins
xcopy /q %DEPSDIR%\postgresql\src\interfaces\libpq\libpq-fe.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\postgresql\src\include\postgres_ext.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\postgresql\src\include\pg_config_ext.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\sqlite\sqlite3.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q %DEPSDIR%\gdal\gcore\*h %MAPNIK_SDK%\includes\gdal\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_feature.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_spatialref.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_geometry.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_core.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_featurestyle.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogrsf_frmts\ogrsf_frmts.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\ogr\ogr_srs_api.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gcore\gdal_priv.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gcore\gdal_frmts.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gcore\gdal.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gcore\gdal_version.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_minixml.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_atomic_ops.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_string.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_conv.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_vsi.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_virtualmem.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_error.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_progress.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_port.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\port\cpl_config.h %MAPNIK_SDK%\includes\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: libs for plugins
xcopy /q %DEPSDIR%\postgresql\src\interfaces\libpq\Release\libpq.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\postgresql\src\interfaces\libpq\Release\libpq.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\sqlite\sqlite3.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gdal_i.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:: NOTE: impossible to statically link gdal due to:
:: http://stackoverflow.com/questions/4596212/c-odbc-refuses-to-statically-link-to-libcmt-lib-under-vs2010
::xcopy /q %DEPSDIR%\gdal\gdal.lib %MAPNIK_SDK%\libs\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\gdal\gdal111.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\expat\win32\bin\Release\libexpat.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q %DEPSDIR%\expat\win32\bin\Release\libexpat.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: detect trouble with mimatched linking
::dumpbin /directives %MAPNIK_SDK%\libs\*lib | grep LIBCMT

::msbuild /m:2 /t:mapnik /p:BuildInParellel=true .\build\mapnik.sln /p:Configuration=Release

msbuild ^
/m:%NUMBER_OF_PROCESSORS% ^
/p:BuildInParellel=true ^
.\build\mapnik.sln ^
/p:Configuration=Release ^
/toolsversion:%TOOLS_VERSION% ^
/p:Platform=%BUILDPLATFORM%

:: /t:rebuild
:: /v:diag > build.log
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:: install mapnik libs
xcopy /q .\build\Release\mapnik.lib %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q .\build\Release\mapnik.dll %MAPNIK_SDK%\libs\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /q ..\fonts\dejavu-fonts-ttf-2.33\ttf\*ttf %MAPNIK_SDK%\libs\mapnik\fonts\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:: move python binding into local testable location
xcopy /q .\build\Release\_mapnik.pyd ..\bindings\python\mapnik\ /Y
echo from os.path import normpath,join,dirname > ..\bindings\python\mapnik\paths.py
echo mapniklibpath = '%MAPNIK_SDK%/libs/mapnik' >> ..\bindings\python\mapnik\paths.py
echo mapniklibpath = normpath(join(dirname(__file__),mapniklibpath)) >> ..\bindings\python\mapnik\paths.py
echo inputpluginspath = join(mapniklibpath,'input') >> ..\bindings\python\mapnik\paths.py
echo fontscollectionpath = join(mapniklibpath,'fonts') >> ..\bindings\python\mapnik\paths.py
echo __all__ = [mapniklibpath,inputpluginspath,fontscollectionpath] >> ..\bindings\python\mapnik\paths.py

:: plugins
xcopy  /q .\build\Release\*input %MAPNIK_SDK%\libs\mapnik\input\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: install mapnik headers
xcopy /i /d /s /q ..\deps\mapnik\sparsehash %MAPNIK_SDK%\includes\mapnik\sparsehash /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\deps\agg\include %MAPNIK_SDK%\includes\mapnik\agg /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\deps\clipper\include %MAPNIK_SDK%\includes\mapnik\agg /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\include\mapnik %MAPNIK_SDK%\includes\mapnik /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: run tests
SET PATH=%MAPNIK_SDK%\libs;%PATH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
for %%t in (build\Release\*test.exe) do ( call %%t -d %CD%\.. )
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST get-pip.py (
    wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
    python get-pip.py
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
    C:\Python27\Scripts\pip.exe install nose
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)
xcopy /i /d /s /q .\build\Release\_mapnik.pyd ..\bindings\python\mapnik\_mapnik.pyd /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %ERRORLEVEL% NEQ 0 GOTO ERROR
SET GDAL_DATA=%MAPNIK_SDK%\share\gdal
if NOT EXIST %GDAL_DATA% (
  mkdir %GDAL_DATA%
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)
SET PROJ_LIB=%MAPNIK_SDK%\share\proj
if NOT EXIST %PROJ_LIB% (
  mkdir %PROJ_LIB%
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)
SET ICU_DATA=%MAPNIK_SDK%\share\icu
if NOT EXIST %ICU_DATA% (
  mkdir %ICU_DATA%
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

if NOT EXIST %MAPNIK_SDK%\share\icu\icudt53l.dat (
    wget --no-check-certificate https://github.com/mapnik/mapnik-packaging/raw/master/osx/icudt53l_only_collator_and_breakiterator.dat
    xcopy /q icudt53l_only_collator_and_breakiterator.dat %MAPNIK_SDK%\share\icu\icudt53l.dat /Y
)

SET PYTHONPATH=%CD%\..\bindings\python
python ..\tests\run_tests.py -q
::python ..\tests\visual_tests\test.py -q

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------
echo ERRORLEVEL %ERRORLEVEL%

:DONE
echo DONE building Mapnik

EXIT /b %ERRORLEVEL%
