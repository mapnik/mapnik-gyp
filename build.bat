@echo off

::git clone https://chromium.googlesource.com/external/gyp.git
::CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86
::SET PATH=C:\Python27;%PATH%

::ddt %MAPNIK_SDK%
::IF ERRORLEVEL NEQ 0 GOTO ERROR
::ddt build\Release
::IF ERRORLEVEL NEQ 0 GOTO ERROR

if EXIST gyp ECHO gyp already cloned && GOTO GYP_ALREADY_HERE

CALL git clone https://chromium.googlesource.com/external/gyp.git gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::modify gyp to see where it hangs during autmated builds
::CD gyp
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::patch -N -p1 < %PATCHES%/__DELME-GYP-HANG-TEST.diff || %SKIP_FAILED_PATCH%
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::CD ..
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:GYP_ALREADY_HERE

SET PLATFORMX=x64
IF "%BUILDPLATFORM%"=="Win32" SET PLATFORMX=x86
:: run find command and bail on error
:: this ensures we have the unix find command on path
:: before trying to run gyp
ECHO testing unix find command
find ../deps/agg/src/ -name "*.cpp"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF DEFINED PACKAGEDEBUGSYMBOLS (ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%) ELSE (SET PACKAGEDEBUGSYMBOLS=0)
IF DEFINED IGNOREFAILEDTESTS (ECHO IGNOREFAILEDTESTS %IGNOREFAILEDTESTS%) ELSE (SET IGNOREFAILEDTESTS=0)
IF DEFINED FASTBUILD (ECHO FASTBUILD %FASTBUILD%) ELSE (SET FASTBUILD=0)
IF DEFINED PACKAGEDEPS (ECHO PACKAGEDEPS %PACKAGEDEPS%) ELSE (SET PACKAGEDEPS=0)

SET MAPNIK_SDK=%CD%\mapnik-sdk
SET DEPSDIR=..\..

ECHO mapnik SDK directory^: %MAPNIK_SDK%
ECHO DEPSDIR^: %DEPSDIR%

IF EXIST %MAPNIK_SDK% (ECHO SDK directory found && GOTO MAPNIK_SDK_DIR_CREATED)

ECHO creating mapnik SDK directory
mkdir %MAPNIK_SDK%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\bin
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\include
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\share
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\lib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\lib\mapnik\input
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir %MAPNIK_SDK%\lib\mapnik\fonts
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:MAPNIK_SDK_DIR_CREATED
ECHO label MAPNIK_SDK_DIR_CREATED

:: includes
IF DEFINED ICU_VERSION (FOR /f "delims=." %%G IN ("%ICU_VERSION%") DO SET ICU_VERSION=%%G) ELSE (SET ICU_VERSION=55)

IF %FASTBUILD% EQU 1 (ECHO doing a FASTBUILD && GOTO DOFASTBUILD) ELSE (ECHO doing a FULLBUILD)

ECHO copying deps header files...

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
::xcopy /i /d /s /q %DEPSDIR%\libxml2\include %MAPNIK_SDK%\include\libxml2 /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
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
xcopy /q /d %DEPSDIR%\libjpegturbo\jpeglib.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\jmorecfg.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\build\jconfig.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\build\jconfigint.h %MAPNIK_SDK%\include\ /Y
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
ECHO copying deps lib files...
xcopy /q /d %DEPSDIR%\harfbuzz-build\harfbuzz.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\freetype\freetype.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


SET ICU_PATH_POSTFIX=
SET ICU_FILE_POSTFIX=
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


::xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a.lib %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2_a_dll.lib %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.dll %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /q /d %DEPSDIR%\libxml2\win32\bin.msvc\libxml2.lib %MAPNIK_SDK%\lib\ /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

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
xcopy /q /d %DEPSDIR%\libjpegturbo\build\sharedlib\%BUILD_TYPE%\jpeg.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\build\sharedlib\%BUILD_TYPE%\jpeg62.dll %MAPNIK_SDK%\lib\ /Y
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
ECHO copying deps additional data files...
xcopy /i /d /s /q %DEPSDIR%\proj\nad %MAPNIK_SDK%\share\proj /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %DEPSDIR%\gdal\data %MAPNIK_SDK%\share\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: bin
::copy mapnik-config.bat after all necessary files have been copied, to
::allow for autocreation of "dep libs"
ECHO copying deps bin files...
IF %TARGET_ARCH% EQU 32 (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILD_TYPE%\protoc.exe %MAPNIK_SDK%\bin\ /Y
) ELSE (
  xcopy /q /d %DEPSDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\protoc.exe %MAPNIK_SDK%\bin\ /Y
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: headers for plugins
ECHO copying headers for plugins...
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
xcopy /q /d %DEPSDIR%\gdal\ogr\ogr_api.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
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
xcopy /q /d %DEPSDIR%\gdal\port\cpl_multiproc.h %MAPNIK_SDK%\include\ /Y
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
ECHO copying libs for plugins...
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

:: jump to build when not packaging deps
IF %PACKAGEDEPS% EQU 0 ECHO NOT packaging deps && GOTO RUNMAPNIKBUILD

ECHO packaging deps...
SET CURRENTBUILDDIR=%CD%
CD %MAPNIK_SDK%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CD ..
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEP_PKG_FILENAME=mapnik-win-sdk-binary-deps-%TOOLS_VERSION%-%PLATFORMX%.7z
IF EXIST %DEP_PKG_FILENAME% DEL /Q %DEP_PKG_FILENAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL 7z a -r -mx9 %DEP_PKG_FILENAME% %MAPNIK_SDK% | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %ROOTDIR%\bin\%DEP_PKG_FILENAME% DEL /Q %ROOTDIR%\bin\%DEP_PKG_FILENAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
COPY %DEP_PKG_FILENAME% %ROOTDIR%\bin\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO dependencies package copied to %ROOTDIR%\bin\%DEP_PKG_FILENAME%
CD %CURRENTBUILDDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:RUNMAPNIKBUILD
ECHO label RUNMAPNIKBUILD
:: detect trouble with mimatched linking
::dumpbin /directives %MAPNIK_SDK%\lib\*lib | grep LIBCMT

::msbuild /m:2 /t:mapnik /p:BuildInParellel=true .\build\mapnik.sln /p:Configuration=Release

:DOFASTBUILD
ECHO label DOFASTBUILD

ECHO INCLUDE %INCLUDE%

ECHO generating solution file, calling gyp...
CALL gyp\gyp.bat mapnik.gyp --depth=. ^
 --debug=all ^
 -Dincludes=%MAPNIK_SDK%/include ^
 -Dlibs=%MAPNIK_SDK%/lib ^
 -Dconfiguration=%BUILD_TYPE% ^
 -Dplatform=%BUILDPLATFORM% ^
 -Dboost_version=1_%BOOST_VERSION% ^
 -f msvs -G msvs_version=2015 ^
 --generator-output=build
IF %ERRORLEVEL% NEQ 0 (ECHO error during solution file generation && GOTO ERROR) ELSE (ECHO solution file generated)

SET MSBUILD_VERBOSITY=
IF NOT DEFINED VERBOSE SET VERBOSE=0
IF %VERBOSE% EQU 1 ECHO !!!!!! using msbuild verbosity diagnostic !!!!! && SET MSBUILD_VERBOSITY=/verbosity:diagnostic

ECHO calling msbuild...
msbuild ^
.\build\mapnik.sln ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParellel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% %MSBUILD_VERBOSITY%


:: /t:rebuild
:: /v:diag > build.log
ECHO msbuild ERRORLEVEL^: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (ECHO error during build && GOTO ERROR) ELSE (ECHO build finished)


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

xcopy /q /d ..\fonts\dejavu-fonts-ttf-2.35\ttf\*ttf %MAPNIK_SDK%\lib\mapnik\fonts\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: plugins
xcopy  /q .\build\lib\mapnik\input\*.input %MAPNIK_SDK%\lib\mapnik\input\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::write batch file to set mapnik environment vars
echo @ECHO OFF> %MAPNIK_SDK%\set-env-vars.bat
echo SET SDKDIR=%%~dp0>> %MAPNIK_SDK%\set-env-vars.bat
echo SET ICU_DATA=%%SDKDIR%%share\icu>> %MAPNIK_SDK%\set-env-vars.bat
echo SET GDAL_DATA=%%SDKDIR%%\share\gdal>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PROJ_LIB=%%SDKDIR%%\share\proj>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PATH=%%SDKDIR%%bin;%%PATH%%>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PATH=%%SDKDIR%%lib;%%PATH%%>> %MAPNIK_SDK%\set-env-vars.bat


::copy demo data and demo apps
xcopy /q /d /i /s ..\demo  %MAPNIK_SDK%\demo


:: install mapnik headers
xcopy /i /d /s /q ..\deps\mapnik\sparsehash %MAPNIK_SDK%\include\mapnik\sparsehash /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\deps\agg\include %MAPNIK_SDK%\include\mapnik\agg /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q ..\include\mapnik %MAPNIK_SDK%\include\mapnik /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::create and copy mapnik-config.bat
::do this after copying the headers, to allow parsing of version.hpp for mapnik version
SET MAPNIK_GIT_DESCRIBE=
SET MAPNIK_GIT_REVISION=
ECHO stepping down into mapnik && CD ..
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO doing git describe... && FOR /F "tokens=*" %%i in ('git describe') do SET MAPNIK_GIT_DESCRIBE=%%i
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO doing git rev-list... && FOR /F "tokens=*" %%i in ('git rev-list --max-count=1 HEAD') do SET MAPNIK_GIT_REVISION=%%i
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO stepping up into mapnik-gyp && CD mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
powershell .\mapnik-config-create.ps1
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d mapnik-config.bat %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 ECHO could not copy mapnik-config.bat && GOTO ERROR


::copy debug symbols
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %PACKAGEDEBUGSYMBOLS% EQU 1 powershell %ROOTDIR%\scripts\package_mapnik_debug_symbols.ps1
ECHO ERRORLEVEL %ERRORLEVEL%
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

:: change into mapnik directory!!! TESTS!!
CD ..

ECHO ============================ prepare TESTS ==========================
:: copy input plugins where expected by tests
copy /Y mapnik-gyp\build\lib\mapnik\input\*.input plugins\input\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO ============================ running TESTS ==========================
:: run tests
SET PATH=%MAPNIK_SDK%\lib;%PATH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
for %%t in (mapnik-gyp\build\test\*test.exe) do ( call %%t -d yes )
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO about to benchmark && CALL mapnik-gyp\benchmark.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO ============================ clean up after TESTS ==========================
ECHO !!!!!!! !!!!! !!!!!! NOT REMOVING PLUGINS COPY DURING benchmark testing
ECHO !!!!!!! !!!!! !!!!!! TODO: enable again! ! ! ! ! !
::DEL /F plugins\input\*.input
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST %MAPNIK_SDK%\share\icu\icudt%ICU_VERSION%l.dat (
    wget --no-check-certificate https://github.com/mapnik/mapnik-packaging/raw/master/osx/icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat
    echo f | xcopy /q /d /Y icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat %MAPNIK_SDK%\share\icu\icudt%ICU_VERSION%l.dat
)

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------
echo ERRORLEVEL %ERRORLEVEL%

:DONE
echo DONE building Mapnik

EXIT /b %ERRORLEVEL%
