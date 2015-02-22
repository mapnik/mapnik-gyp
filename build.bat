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

SET PLATFORMX=x64
IF "%BUILDPLATFORM%"=="Win32" SET PLATFORMX=x86
:: run find command and bail on error
:: this ensures we have the unix find command on path
:: before trying to run gyp
find ../deps/clipper/src/ -name "*.cpp"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF DEFINED PACKAGEDEBUGSYMBOLS (ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%) ELSE (SET PACKAGEDEBUGSYMBOLS=0)
IF DEFINED IGNOREFAILEDTESTS (ECHO IGNOREFAILEDTESTS %IGNOREFAILEDTESTS%) ELSE (SET IGNOREFAILEDTESTS=0)

SET MAPNIK_SDK=%CD%\mapnik-sdk
SET DEPSDIR=..\..

CALL gyp\gyp.bat mapnik.gyp --depth=. ^
 -Dincludes=%MAPNIK_SDK%/include ^
 -Dlibs=%MAPNIK_SDK%/lib ^
 -Dconfiguration=%BUILD_TYPE% ^
 -Dplatform=%BUILDPLATFORM% ^
 -f msvs -G msvs_version=2013 ^
 --generator-output=build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST %MAPNIK_SDK% (
  mkdir %MAPNIK_SDK%
  mkdir %MAPNIK_SDK%\bin
  mkdir %MAPNIK_SDK%\include
  mkdir %MAPNIK_SDK%\share
  mkdir %MAPNIK_SDK%\lib
  mkdir %MAPNIK_SDK%\lib\mapnik\input
  mkdir %MAPNIK_SDK%\lib\mapnik\fonts
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:: includes
SET PYTHON_DIR=%ROOTDIR%\tmp-bin\python2-x86-32
if %BOOSTADDRESSMODEL% EQU 64 (
  SET PYTHON_DIR=%ROOTDIR%\tmp-bin\python2
)
::xcopy /Q /D /Y %PYTHON_INCLUDE_DIR%\*.* %MAPNIK_SDK%\include\python
xcopy /Q /D /Y %PYTHON_DIR%\include\*.* %MAPNIK_SDK%\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::SET INCLUDE=%MAPNIK_SDK%\include\python;%INCLUDE%
xcopy /Q /D /Y %PYTHON_DIR%\libs\python27.lib %MAPNIK_SDK%\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /q /d %DEPSDIR%\harfbuzz-build\harfbuzz\hb-version.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-shape-plan.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-shape.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-set.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-ft.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-buffer.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-unicode.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-common.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-blob.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-font.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-face.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\harfbuzz\src\hb-deprecated.h %MAPNIK_SDK%\include\harfbuzz\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\boost\boost %MAPNIK_SDK%\include\boost /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\icu\include\unicode %MAPNIK_SDK%\include\unicode /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\freetype\include %MAPNIK_SDK%\include\freetype2 /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\libxml2\include %MAPNIK_SDK%\include\libxml2 /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\zlib\zlib.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\zlib\zconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libpng\png.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libpng\pnglibconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libpng\pngconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\jpeg\jpeglib.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\jpeg\jconfig.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\jpeg\jmorecfg.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\webp\src\webp %MAPNIK_SDK%\include\webp /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\proj\src\proj_api.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiff.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffvers.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffio.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\cairo-version.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-features.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-deprecated.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-svg.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-svg-surface-private.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-pdf.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-ft.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\cairo-ps.h %MAPNIK_SDK%\include\cairo\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\protobuf\src\google %MAPNIK_SDK%\include\google /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: libs
xcopy /q /d %DEPSDIR%\harfbuzz-build\harfbuzz.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\freetype\freetype.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


SET ICU_PATH_POSTFIX=
SET ICU_FILE_POSTFIX=
SET ICU_VERSION=54
if %BOOSTADDRESSMODEL% EQU 64 (SET ICU_PATH_POSTFIX=64)
IF %BUILD_TYPE% EQU Debug (SET ICU_FILE_POSTFIX=d)
xcopy /q /d %DEPSDIR%\icu\lib%ICU_PATH_POSTFIX%\icuuc%ICU_FILE_POSTFIX%.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\icu\lib%ICU_PATH_POSTFIX%\icuin%ICU_FILE_POSTFIX%.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\icu\lib%ICU_PATH_POSTFIX%\icudt%ICU_FILE_POSTFIX%.lib %MAPNIK_SDK%\lib\ /Y
xcopy /q /d %DEPSDIR%\icu\lib%ICU_PATH_POSTFIX%\icudt.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\icu\bin%ICU_PATH_POSTFIX%\icuuc%ICU_VERSION%%ICU_FILE_POSTFIX%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\icu\bin%ICU_PATH_POSTFIX%\icuin%ICU_VERSION%%ICU_FILE_POSTFIX%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\icu\bin%ICU_PATH_POSTFIX%\icudt%ICU_VERSION%%ICU_FILE_POSTFIX%.dll %MAPNIK_SDK%\lib\ /Y
xcopy /q /d %DEPSDIR%\icu\bin%ICU_PATH_POSTFIX%\icudt%ICU_VERSION%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a_dll.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\libtiff.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /i /d /s /q %DEPSDIR%\libtiff\libtiff\libtiff.lib %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\libtiff_i.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::static zlib
xcopy /q /d %DEPSDIR%\zlib\zlib.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::shared zlib
SET BT=Debug
IF "%BUILD_TYPE%"=="Release" SET BT=ReleaseWithoutAsm
xcopy /q /d %DEPSDIR%\zlib\contrib\vstudio\vc11\%PLATFORMX%\ZlibDll%BT%\zlibwapi.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\zlib\contrib\vstudio\vc11\%PLATFORMX%\ZlibDll%BT%\zlibwapi.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\proj\src\proj.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET WEBP_FILE_SUFFIX=
IF %BUILD_TYPE% EQU Debug (SET WEBP_FILE_SUFFIX=_debug)
xcopy /q /d %DEPSDIR%\webp\output\%BUILD_TYPE%-dynamic\%WEBP_PLATFORM%\lib\libwebp%WEBP_FILE_SUFFIX%_dll.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\webp\output\%BUILD_TYPE%-dynamic\%WEBP_PLATFORM%\bin\libwebp%WEBP_FILE_SUFFIX%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if "%BOOSTADDRESSMODEL%"=="64" (
  xcopy /q /d %DEPSDIR%\libpng\projects\vstudio\x64\%BUILD_TYPE%\libpng16.lib %MAPNIK_SDK%\lib\ /Y
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  xcopy /q /d %DEPSDIR%\libpng\projects\vstudio\x64\%BUILD_TYPE%\libpng16.dll %MAPNIK_SDK%\lib\ /Y
) ELSE (
  xcopy /q /d %DEPSDIR%\libpng\projects\vstudio\%BUILD_TYPE%\libpng16.lib %MAPNIK_SDK%\lib\ /Y
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  xcopy /q /d %DEPSDIR%\libpng\projects\vstudio\%BUILD_TYPE%\libpng16.dll %MAPNIK_SDK%\lib\ /Y
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\jpeg\libjpeg.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\%BUILD_TYPE%\cairo-static.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\%BUILD_TYPE%\cairo.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\cairo\src\%BUILD_TYPE%\cairo.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\boost\stage\lib\*.* %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %TARGET_ARCH% EQU 32 (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILD_TYPE%\libprotobuf-lite.lib %MAPNIK_SDK%\lib\ /Y
) ELSE (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf-lite.lib %MAPNIK_SDK%\lib\ /Y
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: pdb
REM IF %BUILD_TYPE% EQU Debug (
REM   ECHO %MAPNIK_SDK%\lib\ > EXCLUDES.TXT
REM   xcopy /Y /S /exclude:EXCLUDES.TXT %DEPSDIR%\*.pdb %MAPNIK_SDK%\lib\
REM   REM DEL EXCLUDES.TXT
REM )
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:: data
xcopy /i /d /s /q %DEPSDIR%\proj\nad %MAPNIK_SDK%\share\proj /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\gdal\data %MAPNIK_SDK%\share\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: bin
IF %TARGET_ARCH% EQU 32 (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILD_TYPE%\protoc.exe %MAPNIK_SDK%\bin\ /Y
) ELSE (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\protoc.exe %MAPNIK_SDK%\bin\ /Y
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d mapnik-config.bat %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: headers for plugins
xcopy /q /d %DEPSDIR%\postgresql\src\interfaces\libpq\libpq-fe.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\postgresql\src\include\postgres_ext.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\postgresql\src\include\pg_config_ext.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\sqlite\sqlite3.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\gdal\gcore\*h %MAPNIK_SDK%\include\gdal\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_feature.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_spatialref.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_geometry.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_core.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_featurestyle.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogrsf_frmts\ogrsf_frmts.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_srs_api.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gcore\gdal_priv.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gcore\gdal_frmts.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gcore\gdal.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gcore\gdal_version.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_minixml.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_atomic_ops.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_string.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_conv.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_vsi.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_virtualmem.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_error.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_progress.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_port.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\port\cpl_config.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: libs for plugins
SET LIBPQ_FILE_SUFFIX=
IF %BUILD_TYPE% EQU Debug (SET LIBPQ_FILE_SUFFIX=d)
xcopy /q /d %DEPSDIR%\postgresql\src\interfaces\libpq\%BUILD_TYPE%\libpq%LIBPQ_FILE_SUFFIX%.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\postgresql\src\interfaces\libpq\%BUILD_TYPE%\libpq%LIBPQ_FILE_SUFFIX%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /q /d %DEPSDIR%\sqlite\sqlite3.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gdal_i.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:: NOTE: impossible to statically link gdal due to:
:: http://stackoverflow.com/questions/4596212/c-odbc-refuses-to-statically-link-to-libcmt-lib-under-vs2010
::xcopy /q /d %DEPSDIR%\gdal\gdal.lib %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\gdal\gdal%GDAL_VERSION_FILE%.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\expat\win32\bin\%BUILD_TYPE%\libexpat.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\expat\win32\bin\%BUILD_TYPE%\libexpat.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: detect trouble with mimatched linking
::dumpbin /directives %MAPNIK_SDK%\lib\*lib | grep LIBCMT

::msbuild /m:2 /t:mapnik /p:BuildInParellel=true .\build\mapnik.sln /p:Configuration=Release

ECHO INCLUDE %INCLUDE%

msbuild ^
.\build\mapnik.sln ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParellel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM%

:: /t:rebuild
:: /v:diag > build.log
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: install command line tools
xcopy /q /d .\build\bin\nik2img.exe %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\bin\shapeindex.exe %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: install mapnik libs
xcopy /q /d .\build\%BUILD_TYPE%\mapnik.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\%BUILD_TYPE%\lib\mapnik-json.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\%BUILD_TYPE%\lib\mapnik-wkt.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\lib\mapnik.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: install additional bins
xcopy /q /d .\build\bin\shapeindex.exe %MAPNIK_SDK%\bin\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /q /d ..\fonts\dejavu-fonts-ttf-2.34\ttf\*ttf %MAPNIK_SDK%\lib\mapnik\fonts\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:: move python binding into local testable location
:: * hack from http://stackoverflow.com/a/14488464/2333354
:: because otherwise xcopy can't tell if its a file or directory and will prompt
xcopy /q /s /d .\build\lib\python2.7\mapnik\_mapnik.pyd ..\bindings\python\mapnik\_mapnik.pyd* /Y
echo from os.path import normpath,join,dirname > ..\bindings\python\mapnik\paths.py
echo mapniklibpath = '%MAPNIK_SDK%/lib/mapnik' >> ..\bindings\python\mapnik\paths.py
echo mapniklibpath = normpath(join(dirname(__file__),mapniklibpath)) >> ..\bindings\python\mapnik\paths.py
echo inputpluginspath = join(mapniklibpath,'input') >> ..\bindings\python\mapnik\paths.py
echo fontscollectionpath = join(mapniklibpath,'fonts') >> ..\bindings\python\mapnik\paths.py
echo __all__ = [mapniklibpath,inputpluginspath,fontscollectionpath] >> ..\bindings\python\mapnik\paths.py

:: plugins
xcopy  /q .\build\lib\mapnik\input\*.input %MAPNIK_SDK%\lib\mapnik\input\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::copy python bindings
xcopy /q /d ..\bindings\python\mapnik\*.*  %MAPNIK_SDK%\python\2.7\site-packages\mapnik\

::write batch file to set mapnik environment vars
echo @ECHO OFF> %MAPNIK_SDK%\set-env-vars.bat
echo SET SDKDIR=%%~dp0>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PYTHONPATH=%%SDKDIR%%python\2.7\site-packages;%%PYTHONPATH%%>> %MAPNIK_SDK%\set-env-vars.bat
::echo SET MAPNIK_INPUT_PLUGINS_DIRECTORY=%%SDKDIR%%lib\mapnik\input>> %MAPNIK_SDK%\set-env-vars.bat
echo SET ICU_DATA=%%SDKDIR%%share\icu>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PATH=%%SDKDIR%%bin;%%PATH%%>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PATH=%%SDKDIR%%lib;%%PATH%%>> %MAPNIK_SDK%\set-env-vars.bat


::copy demo data and demo apps
xcopy /q /d /i /s ..\demo  %MAPNIK_SDK%\demo


:: install mapnik headers
xcopy /i /d /s /q ..\deps\mapnik\sparsehash %MAPNIK_SDK%\include\mapnik\sparsehash /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\deps\agg\include %MAPNIK_SDK%\include\mapnik\agg /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\deps\clipper\include %MAPNIK_SDK%\include\mapnik\agg /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\include\mapnik %MAPNIK_SDK%\include\mapnik /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::copy debug symbols
powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %PACKAGEDEBUGSYMBOLS% EQU 1 powershell %ROOTDIR%\scripts\package_mapnik_debug_symbols.ps1
ECHO ERRORLEVEL %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


ECHO ============================ running TESTS ==========================
:: run tests
SET PATH=%MAPNIK_SDK%\lib;%PATH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
for %%t in (build\test\*test.exe) do ( call %%t -d %CD%\.. )
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST get-pip.py (
    wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
    python get-pip.py
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
    pip.exe install nose
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

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

if NOT EXIST %MAPNIK_SDK%\share\icu\icudt%ICU_VERSION%l.dat (
    wget --no-check-certificate https://github.com/mapnik/mapnik-packaging/raw/master/osx/icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat
    echo f | xcopy /q /d /Y icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat %MAPNIK_SDK%\share\icu\icudt%ICU_VERSION%l.dat
)

SET PYTHONPATH=%CD%\..\bindings\python
:: all visual tests should pass on windows
:: some python tests are expected to fail
::python ..\tests\run_tests.py -q
python ..\tests\visual_tests\test.py -q
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------
echo ERRORLEVEL %ERRORLEVEL%

:DONE
echo DONE building Mapnik

EXIT /b %ERRORLEVEL%
