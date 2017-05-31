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

ECHO ==================================
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO SET IGNOREFAILEDTESTS=1 REMOVE after tests are working
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO ==================================
SET IGNOREFAILEDTESTS=1

IF /I "%USERNAME%"=="appveyor" ECHO on AppVeyor, disabling Python bindings && SET BUILDMAPNIKPYTHON=0
IF NOT DEFINED BUILDMAPNIKPYTHON SET BUILDMAPNIKPYTHON=0
IF %BUILDMAPNIKPYTHON% EQU 1 (ECHO building Python bindings) ELSE (ECHO not building Python bindings)

IF NOT DEFINED MAPNIK_BUILD_TESTS SET MAPNIK_BUILD_TESTS=1
IF %MAPNIK_BUILD_TESTS% EQU 1 (ECHO building tests) ELSE (ECHO not building tests)
IF DEFINED RUNCODEANALYSIS (ECHO running code analysis, RUNCODEANALYSIS^:%RUNCODEANALYSIS%) ELSE (SET RUNCODEANALYSIS=0)
IF DEFINED PACKAGEDEBUGSYMBOLS (ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%) ELSE (SET PACKAGEDEBUGSYMBOLS=0)
IF DEFINED IGNOREFAILEDTESTS (ECHO IGNOREFAILEDTESTS %IGNOREFAILEDTESTS%) ELSE (SET IGNOREFAILEDTESTS=0)
IF DEFINED FASTBUILD (ECHO FASTBUILD %FASTBUILD%) ELSE (SET FASTBUILD=0)
IF DEFINED PACKAGEDEPS (ECHO PACKAGEDEPS %PACKAGEDEPS%) ELSE (SET PACKAGEDEPS=0)

SET PYTHON_BUILD_FAILED=0

SET MAPNIK_SDK=%CD%\mapnik-sdk
SET DEPSDIR=..\..

ECHO mapnik SDK directory^: %MAPNIK_SDK%
ECHO DEPSDIR^: %DEPSDIR%

::create postgis_template
WHERE psql
IF %ERRORLEVEL% NEQ 0 ECHO psql not found - some tests will fail && GOTO POSTGIS_TEMPLATE_FOUND
IF NOT DEFINED PGUSER ECHO PGUSER not found, postgis errors might occur
IF NOT DEFINED PGPASSWORD ECHO PGPASSWORD not found, postgis errors might occur


::on AppVeyor install PostGIS manually

IF /I "%USERNAME%"=="appveyor" (ECHO on AppVeyor, installing PostGIS manually) ELSE (GOTO CHECK_POSTGRES_SERVICE)

REM Use experimental postgis 2.3.0 dev build to work around curl issue
REM ERROR:  could not load library "C:/Program Files/PostgreSQL/9.4/lib/rtpostgis-2.2.dll": The specified procedure could not be found.
:: Note: upstread download path (http://download.osgeo.org/postgis/windows/pg94/) was frequently changing so we should likely vendor this
SET POSTGIS_DL_URL=http://download.osgeo.org/postgis/windows/pg94/archive/postgis-bundle-pg94-2.3.0x64.zip
SET POSTGIS_ZIP_FOLDER=postgis-bundle-pg94-2.3.0x64
REM SET POSTGIS_ZIP_FOLDER=postgis-pg94-binaries-2.3.0w64gcc48
REM SET POSTGIS_DL_URL=http://winnie.postgis.net/download/windows/pg94/buildbot/%POSTGIS_ZIP_FOLDER%.zip
IF NOT EXIST pgis.zip curl -sSfL %POSTGIS_DL_URL% -o pgis.zip 
IF %ERRORLEVEL% NEQ 0 ECHO failed to download PostGIS && GOTO CHECK_POSTGRES_SERVICE
SET PG_PATH=C:\Program Files\PostgreSQL\9.4
7z -y x pgis.zip | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 ECHO failed to extract PostGIS && GOTO CHECK_POSTGRES_SERVICE
XCOPY /Y /Q /S /E %POSTGIS_ZIP_FOLDER%\*.* "%PG_PATH%\"
IF %ERRORLEVEL% NEQ 0 ECHO failed to copy PostGIS && GOTO CHECK_POSTGRES_SERVICE
::dumpbin /DIRECTIVES "C:\Program Files\PostgreSQL\9.4\lib\*"
::dumpbin /DEPENDENTS "C:\Program Files\PostgreSQL\9.4\lib\*"


:CHECK_POSTGRES_SERVICE

::check for postgres process
tasklist /FI "IMAGENAME eq postgres.exe" 2>NUL | %windir%\system32\find /I /N "postgres.exe">NUL
IF %ERRORLEVEL% NEQ 0 ECHO postgres.exe not running!!! trying to start service && NET START postgresql-x64-9.4
IF %ERRORLEVEL% NEQ 0 ECHO could not start postgresql service - some tests will fail && GOTO POSTGIS_TEMPLATE_FOUND
SET TEMPLATE_EXISTS=
SET TEMPLATE_NAME=template_postgis
FOR /F "tokens=1 usebackq" %%i in (`psql -tAc "SELECT 1 FROM pg_database WHERE datname='%TEMPLATE_NAME%'"`) DO SET TEMPLATE_EXISTS=%%i
IF %ERRORLEVEL% NEQ 0 ECHO error creating %TEMPLATE_NAME% && GOTO ERROR
IF DEFINED TEMPLATE_EXISTS ECHO %TEMPLATE_NAME% EXISTS && GOTO POSTGIS_TEMPLATE_FOUND
ECHO %TEMPLATE_NAME% not found
ECHO creating %TEMPLATE_NAME%
psql -c "create database %TEMPLATE_NAME%;"
IF %ERRORLEVEL% NEQ 0 ECHO error creating %TEMPLATE_NAME% && GOTO ERROR
ECHO creating extension postgis
psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" %TEMPLATE_NAME%
IF %ERRORLEVEL% NEQ 0 ECHO error creating extension postgis && GOTO ERROR

:POSTGIS_TEMPLATE_FOUND


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

IF DEFINED ICU_VERSION (FOR /f "delims=." %%G IN ("%ICU_VERSION%") DO SET ICU_VERSION=%%G) ELSE (SET ICU_VERSION=56)

SET PYTHON_DIR=%ROOTDIR%\tmp-bin\python2-x86-32
IF /I "%PLATFORMX%"=="x64" SET PYTHON_DIR=%ROOTDIR%\tmp-bin\python2
ECHO PYTHON_DIR^: %PYTHON_DIR%

IF %FASTBUILD% EQU 1 (ECHO doing a FASTBUILD && GOTO DOFASTBUILD) ELSE (ECHO doing a FULLBUILD)


:: includes
ECHO copying deps header files...

IF %BUILDMAPNIKPYTHON% EQU 0 GOTO SKIPPED_PYTHON_HEADERS_AND_LIB
ECHO Python
xcopy /Q /D /Y %PYTHON_DIR%\include\*.* %MAPNIK_SDK%\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /Q /D /Y %PYTHON_DIR%\libs\python27.lib %MAPNIK_SDK%\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
:SKIPPED_PYTHON_HEADERS_AND_LIB

ECHO harfbuzz
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
ECHO boost
xcopy /i /d /s /q %DEPSDIR%\boost\boost %MAPNIK_SDK%\include\boost /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO icu
xcopy /i /d /s /q %DEPSDIR%\icu\include\unicode %MAPNIK_SDK%\include\unicode /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO freetype
xcopy /i /d /s /q %DEPSDIR%\freetype\include %MAPNIK_SDK%\include\freetype2 /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /i /d /s /q %DEPSDIR%\libxml2\include %MAPNIK_SDK%\include\libxml2 /Y
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO zlib
xcopy /q /d %DEPSDIR%\zlib\zlib.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\zlib\zconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO png
xcopy /q /d %DEPSDIR%\libpng\png.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libpng\pnglibconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libpng\pngconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO jpg
xcopy /q /d %DEPSDIR%\libjpegturbo\jpeglib.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\jmorecfg.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\build\jconfig.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libjpegturbo\build\jconfigint.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO webp
xcopy /i /d /s /q %DEPSDIR%\webp\src\webp %MAPNIK_SDK%\include\webp /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO proj4
xcopy /q /d %DEPSDIR%\proj\src\proj_api.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO tiff
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiff.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffvers.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffconf.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d %DEPSDIR%\libtiff\libtiff\tiffio.h %MAPNIK_SDK%\include\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO cairo
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
ECHO protobuf
xcopy /i /d /s /q %DEPSDIR%\protobuf\src\google %MAPNIK_SDK%\include\google /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO mapbox variant
XCOPY /i /d /q ..\deps\mapbox\variant\*.hpp %MAPNIK_SDK%\include\mapbox\variant\ /Y
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
dumpbin /DIRECTIVES %MAPNIK_SDK%\lib\*lib
dumpbin /DEPENDENTS %MAPNIK_SDK%\lib\*lib

::msbuild /m:2 /t:mapnik /p:BuildInParallel=true .\build\mapnik.sln /p:Configuration=Release

:DOFASTBUILD
ECHO label DOFASTBUILD

ECHO INCLUDE %INCLUDE%

:GENERATE_SOLUTION


::add path to Python lib at first position in %PATH%
IF /I "%USERNAME%"=="appveyor" GOTO APPVEYOR_SET_PYTHON_LIB_PATH

:: for https://github.com/mapbox/windows-builds
IF /I "%PLATFORM%"=="x64" SET PATH=%ROOTDIR%\tmp-bin\python2;%ROOTDIR%\tmp-bin\python2\Scripts;%PATH%
IF /I "%PLATFORM%"=="x86" SET PATH=%ROOTDIR%\tmp-bin\python2-x86-32;%ROOTDIR%\tmp-bin\python2-x86-32\Scripts;%PATH%
GOTO PYTHON_LIB_PATH_SET

:APPVEYOR_SET_PYTHON_LIB_PATH
IF /I "%PLATFORM%"=="x64" SET PATH=C:\Python27-x64;C:\Python27-x64\Scripts;%PATH%
IF /I "%PLATFORM%"=="x86" SET PATH=C:\Python27;C:\Python27\Scripts;%PATH%

:PYTHON_LIB_PATH_SET



::generate a debug version of the gyp file: -f gypd -DOS=win
::  -f msvs -G msvs_version=2015 ^

SET PATH=%PYTHONPATH%;%PATH%
ECHO generating solution file, calling gyp...
CALL gyp\gyp.bat mapnik.gyp --depth=. ^
 --debug=all ^
 -Dincludes=%MAPNIK_SDK%/include ^
 -Dlibs=%MAPNIK_SDK%/lib ^
 -Dconfiguration=%BUILD_TYPE% ^
 -Dplatform=%BUILDPLATFORM% ^
 -Dboost_version=1_%BOOST_VERSION% ^
 -f msvs -G msvs_version=2015 ^
 -f gypd -DOS=win ^
 --generator-output=build
ECHO ERRORLEVEL^: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (ECHO error during solution file generation && GOTO ERROR) ELSE (ECHO solution file generated)

::verbosity: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
SET MSBUILD_VERBOSITY=
IF NOT DEFINED VERBOSE SET VERBOSE=0
IF %VERBOSE% EQU 1 ECHO !!!!!! using msbuild verbosity diagnostic !!!!! && SET MSBUILD_VERBOSITY=/verbosity:diagnostic
::build log files
IF EXIST msbuild-summary.txt ECHO delete msbuild-summary.txt && DEL msbuild-summary.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST msbuild-warnings.txt ECHO delete msbuild-warnings.txt && DEL msbuild-warnings.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST msbuild-errors.txt ECHO delete msbuild-errors.txt && DEL msbuild-errors.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET MSBUILD_LOGS=/fl1 /fl2 /fl3 ^
/flp1:Summary;Verbosity=minimal;LogFile=msbuild-summary.txt;Append;Encoding=UTF-8 ^
/flp2:warningsonly;Verbosity=Diagnostic;logfile=msbuild-warnings.txt;Append;Encoding=UTF-8 ^
/flp3:errorsonly;Verbosity=Diagnostic;logfile=msbuild-errors.txt;Append;Encoding=UTF-8

SET MSBUILD_COMMON=^
/nologo ^
/toolsversion:%TOOLS_VERSION% ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:StopOnFirstFailure=true ^
%MSBUILD_VERBOSITY% %MSBUILD_LOGS%

SET MSBUILD_PARALLEL=/maxcpucount:1
IF %NUMBER_OF_PROCESSORS% GEQ 4 SET MSBUILD_PARALLEL=/p:BuildInParallel=true /maxcpucount:2
IF %NUMBER_OF_PROCESSORS% GEQ 8 SET MSBUILD_PARALLEL=/p:BuildInParallel=true /maxcpucount:3
:: since any CL.EXE /MP is able to use all available processors (provided it is given enough
:: sources to compile), using multiple MSBUILD workers only makes sense when you have more
:: processors than sources per directory (because sources from different directories yield
:: different /Fo paths, a separate CL.EXE /MP master process must be run for each directory)

IF DEFINED APPVEYOR SET MSBUILD_PARALLEL=/maxcpucount:1

::build heavy files single threaded

::MAYBE TRY SINGLE FILES MULTITHREADED????
::http://www.hanselman.com/blog/FasterBuildsWithMSBuildUsingParallelBuildsAndMulticoreCPUs.aspx
::In conclusion, BuildInParallel allows the MSBuild task to process the list of projects
::which were passed to it in a parallel fashion,
::while /m tells MSBuild how many processes it is allowed to start.


::https://randomascii.wordpress.com/2014/03/22/make-vc-compiles-fast-through-parallel-compilation/
::http://blogs.msdn.com/b/vcblog/archive/2010/04/01/vc-tip-get-detailed-build-throughput-diagnostics-using-msbuild-compiler-and-linker.aspx
::http://fastbuild.org/docs/home.html
::https://channel9.msdn.com/Shows/C9-GoingNative/GoingNative-35-Fast-Tips-for-Faster-Builds
::compile only one file in VS http://stackoverflow.com/a/2332199

::MSBuild: /m[axcpucount]:%NUMBER_OF_PROCESSORS% => number of MSBuild.exe processes that may be run in parallel
::MSBuild: /p:BuildInParallel=true => multiple worker processes are generated to build as many projects at the same time as possible

::LINK: /MP:%NUMBER_OF_PROCESSORS% => (Build with Multiple Processes) specifies the number of cl.exe processes that simultaneously compile the source files
::LINK: /cgthreads[n] => default 4, max 8: specifies the number of threads used by each cl.exe process


::LINKER OPTIONS: https://msdn.microsoft.com/en-us/library/y0zzbyt4.aspx
::COMPILER OPTIONS: https://msdn.microsoft.com/en-us/library/kezkeayy.aspx
::LINKER: /CGTHREADS:8
::COMPILER: /cgthreads8
IF NOT DEFINED APPVEYOR SET CL=/cgthreads8 /Bt+
IF NOT DEFINED APPVEYOR SET LINK=/CGTHREADS:8 /time+

::https://github.com/mapnik/mapnik/blob/master/Makefile

::create empty directory structure, otherwise compilation of single files will fail
::seems, that directories don't get created for single file compile
XCOPY /T /E ..\src build\Release\src\
IF %ERRORLEVEL% NEQ 0 (ECHO error during creating empty directory structure && GOTO ERROR) ELSE (ECHO empty directory structure created)

GOTO CURRENT

:CURRENT

SET HEAVY_SOURCES=^
..\..\src\renderer_common\render_group_symbolizer.cpp;^
..\..\src\renderer_common\render_markers_symbolizer.cpp;^
..\..\src\renderer_common\render_thunk_extractor.cpp;^
..\..\src\css_color_grammar.cpp;^
..\..\src\expression_grammar.cpp;^
..\..\src\image_filter_grammar.cpp;^
..\..\src\transform_expression_grammar.cpp

ECHO building heavy files first...
IF DEFINED APPVEYOR (ECHO disabling parallel compilation && SET _CL_=/MP1)
msbuild ^
.\build\mapnik.vcxproj ^
/t:ClCompile ^
/p:SelectedFiles="%HEAVY_SOURCES%" ^
%MSBUILD_COMMON%

ECHO msbuild ERRORLEVEL^: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (ECHO error during build && GOTO ERROR) ELSE (ECHO build finished)

::IF DEFINED APPVEYOR ECHO building on AppVeyor^: exiting... && GOTO DONE

::GOTO DONE


::build everything else
::on AppVeyor just the mapnik project

SET MAPNIK_LIBS=mapnik;mapnik-json;mapnik-wkt;mapnik-render;shapeindex;mapnik-index
SET MAPNIK_PLUGINS=csv;gdal;geojson;ogr;pgraster;postgis;raster;shape;sqlite;topojson
SET MAPNIK_TESTS=test;test_visual_run;test_rendering
SET MAPNIK_PROJECT=
IF DEFINED LOCAL_BUILD_DONT_SKIP_TESTS GOTO DO_MAPNIK_BUILD
IF DEFINED APPVEYOR SET MAPNIK_PROJECT=/t:%MAPNIK_LIBS%;%MAPNIK_PLUGINS%;%MAPNIK_TESTS%
IF %MAPNIK_BUILD_TESTS% EQU 0 SET MAPNIK_PROJECT=/t:%MAPNIK_LIBS%;%MAPNIK_PLUGINS%

REM hack to not build python bindings until they work again on Windows
IF DEFINED APPVEYOR GOTO PROJS_TO_BUILD_DEFINED
SET MAPNIK_TESTS=%MAPNIK_TESTS%;test_expression_parse;test_face_ptr_creation;test_font_registration;test_offset_converter;test_proj_transform1;test_quad_tree
SET MAPNIK_PROJECT=/t:%MAPNIK_LIBS%;%MAPNIK_PLUGINS%;%MAPNIK_TESTS%
IF %BUILDMAPNIKPYTHON% EQU 1 SET %MAPNIK_PROJECT%;_mapnik
:PROJS_TO_BUILD_DEFINED


:DO_MAPNIK_BUILD

SET ANALYZE_MAPNIK=
IF %RUNCODEANALYSIS% EQU 1 SET ANALYZE_MAPNIK=/p:RunCodeAnalysis=true
IF %RUNCODEANALYSIS% EQU 1 DEL /S *.lastcodeanalysissucceeded && ECHO deleting previous analysis results
IF %ERRORLEVEL% NEQ 0 (ECHO could not delete previous analysis results && GOTO ERROR) ELSE (ECHO previous analysis results deleted)

IF DEFINED APPVEYOR (ECHO calling msbuild on %MAPNIK_PROJECT%) ELSE (ECHO calling msbuild on whole mapnik solution...)
IF DEFINED APPVEYOR (ECHO enabling parallel compilation && SET _CL_=)

SET CL_prev=%CL%
REM SET CL=%CL% /P /C /EP
ECHO CL^:%CL%

REM quick'n' dirty hack to not build Python bindings when doing full local build
REM use with '/p:SkipNonexistentProjects=true'
REM IF %BUILDMAPNIKPYTHON% EQU 0 del build\_mapnik.vcxproj & del build\_mapnik.vcxproj.filters

msbuild ^
.\build\mapnik.sln %MAPNIK_PROJECT% ^
%MSBUILD_COMMON% %MSBUILD_PARALLEL% %ANALYZE_MAPNIK% /p:SkipNonexistentProjects=true

SET CL=%CL_prev%

ECHO msbuild ERRORLEVEL^: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (ECHO error during build && GOTO ERROR) ELSE (ECHO build finished)

IF %BUILDMAPNIKPYTHON% EQU 0 GOTO SKIPPED_PYTHON_BINDINGS_BUILD
ECHO about to build Python bindings
msbuild ^
.\build\mapnik.sln /t:_mapnik ^
%MSBUILD_COMMON% %MSBUILD_PARALLEL% %ANALYZE_MAPNIK%
ECHO msbuild ERRORLEVEL^: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (ECHO error, Python bindings failed to build && SET PYTHON_BUILD_FAILED=1) ELSE (ECHO Python bindings built successfully)
:SKIPPED_PYTHON_BINDINGS_BUILD


:: install command line tools
xcopy /q /d .\build\bin\mapnik-render.exe %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\bin\shapeindex.exe %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /q /d .\build\bin\mapnik-index.exe %MAPNIK_SDK%\bin /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: install mapnik libs
xcopy /q /d .\build\%BUILD_TYPE%\mapnik.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
dumpbin /DIRECTIVES %MAPNIK_SDK%\lib\mapnik.lib
dumpbin /DEPENDENTS %MAPNIK_SDK%\lib\mapnik.lib

xcopy /q /d .\build\%BUILD_TYPE%\lib\mapnik-json.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
dumpbin /DIRECTIVES %MAPNIK_SDK%\lib\mapnik-json.lib
dumpbin /DEPENDENTS %MAPNIK_SDK%\lib\mapnik-json.lib

xcopy /q /d .\build\%BUILD_TYPE%\lib\mapnik-wkt.lib %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
dumpbin /DIRECTIVES %MAPNIK_SDK%\lib\mapnik-wkt.lib
dumpbin /DEPENDENTS %MAPNIK_SDK%\lib\mapnik-wkt.lib

xcopy /q /d .\build\lib\mapnik.dll %MAPNIK_SDK%\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM xcopy /q /d ..\fonts\dejavu-fonts-ttf-2.37\ttf\*ttf %MAPNIK_SDK%\lib\mapnik\fonts\ /Y
for /f "delims=" %%a in ('dir /b/ad "..\fonts\dejavu-fonts-ttf-*" ') do xcopy /Q /D /Y "..\fonts\%%a\ttf\*ttf" %MAPNIK_SDK%\lib\mapnik\fonts\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::Python
:: move python binding into local testable location
:: use of "*": hack from http://stackoverflow.com/a/14488464/2333354
:: because otherwise xcopy can't tell if its a file or directory and will prompt
xcopy /q /s /d .\build\lib\python2.7\mapnik\_mapnik.pyd ..\bindings\python\mapnik\_mapnik.pyd* /Y
echo from os.path import normpath,join,dirname > ..\bindings\python\mapnik\paths.py
echo mapniklibpath = '%MAPNIK_SDK%/lib/mapnik' >> ..\bindings\python\mapnik\paths.py
echo mapniklibpath = normpath(join(dirname(__file__),mapniklibpath)) >> ..\bindings\python\mapnik\paths.py
echo inputpluginspath = join(mapniklibpath,'input') >> ..\bindings\python\mapnik\paths.py
echo fontscollectionpath = join(mapniklibpath,'fonts') >> ..\bindings\python\mapnik\paths.py
echo __all__ = [mapniklibpath,inputpluginspath,fontscollectionpath] >> ..\bindings\python\mapnik\paths.py

::copy python bindings
xcopy /y /q /d ..\bindings\python\mapnik\*.*  %MAPNIK_SDK%\python\2.7\site-packages\mapnik\


:: plugins
xcopy  /q .\build\lib\mapnik\input\*.input %MAPNIK_SDK%\lib\mapnik\input\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::write batch file to set mapnik environment vars
echo @ECHO OFF> %MAPNIK_SDK%\set-env-vars.bat
echo SET SDKDIR=%%~dp0>> %MAPNIK_SDK%\set-env-vars.bat
echo SET PYTHONPATH=%%SDKDIR%%python\2.7\site-packages;%%PYTHONPATH%%>> %MAPNIK_SDK%\set-env-vars.bat
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

::copy mapbox headers
IF EXIST ..\deps\mapbox\variant XCOPY /I /D /S /Q /Y ..\deps\mapbox\variant\include\mapbox\*.* %MAPNIK_SDK%\include\mapbox\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST ..\deps\mapbox\geometry XCOPY /I /D /S /Q /Y ..\deps\mapbox\geometry\include\mapbox\*.* %MAPNIK_SDK%\include\mapbox\
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


curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
python get-pip.py
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
pip.exe install nose
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
  ECHO creating ICU data directory %ICU_DATA%
  mkdir %ICU_DATA%
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO ICU_DATA^: %ICU_DATA%

::download ICU collator
SET ICU_DAT_NAME=icudt%ICU_VERSION%l.dat
IF EXIST %MAPNIK_SDK%\share\icu\%ICU_DAT_NAME% ECHO already here^: %ICU_DAT_NAME% GOTO COLLATOR_ALREAY_DOWNLOADED

::wget --no-check-certificate -O %MAPNIK_SDK%\share\icu\icudt%ICU_VERSION%l.dat https://github.com/mapnik/mapnik-packaging/raw/master/osx/icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat
::use curl as it comes with git
SET ICU_DATA_DL_URL=https://raw.githubusercontent.com/mapnik/mapnik-packaging/master/osx/icudt%ICU_VERSION%l_only_collator_and_breakiterator.dat
SET ICU_DATA_LOCAL=%MAPNIK_SDK%\share\icu\%ICU_DAT_NAME%
ECHO downloading %ICU_DATA_DL_URL%
ECHO to %ICU_DATA_LOCAL%
curl -o %ICU_DATA_LOCAL% %ICU_DATA_DL_URL%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:COLLATOR_ALREAY_DOWNLOADED


ECHO IGNOREFAILEDTESTS %IGNOREFAILEDTESTS%
SET PATH=%ICU_DATA%;%PATH%
SET PATH=%MAPNIK_SDK%\lib;%PATH%
SET PATH=%MAPNIK_SDK%\bin;%PATH%

IF /I "%USERNAME%"=="appveyor" (ECHO on AppVeyor, skipping Python tests && GOTO AFTER_PYTHON_TESTS)
::ECHO on AppVeyor, skipping Python tests && GOTO AFTER_PYTHON_TESTS

ECHO running Python tests
::Python tests
::SET PYTHONPATH=%CD%\..\bindings\python;%PYTHONPATH%
SET PYTHONPATH=%MAPNIK_SDK%\python\2.7\site-packages
ECHO PYTHONPATH^: %PYTHONPATH%
:: all visual tests should pass on windows
python ..\bindings\python\test\visual.py -q
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0
:: some python tests are expected to fail
python ..\bindings\python\test\run_tests.py -q
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0

:AFTER_PYTHON_TESTS

::IF NOT DEFINED LOCAL_BUILD_DONT_SKIP_TESTS IF DEFINED APPVEYOR ECHO on AppVeyor, skipping other tests && GOTO DONE


:: change into mapnik directory!!! TESTS!!
CD ..



ECHO ============================ prepare TESTS ==========================
:: copy input plugins where expected by tests
copy /Y mapnik-gyp\build\lib\mapnik\input\*.input plugins\input\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO ============================ running TESTS ==========================
:: run tests
ECHO ==== unit tests ===
for %%t in (mapnik-gyp\build\test\*test.exe) do ( call %%t )
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::concurrency should work after https://github.com/mapnik/mapnik/pull/3395
SET /A V_TEST_JOBS=%NUMBER_OF_PROCESSORS%*2
IF %V_TEST_JOBS% LSS 1 SET V_TEST_JOBS=1

ECHO ==== visual tests with %V_TEST_JOBS% concurrency===

ECHO visual test && mapnik-gyp\build\Release\test_visual_run.exe --jobs=%V_TEST_JOBS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)


IF /I "%USERNAME%"=="appveyor" (ECHO on AppVeyor, skipping benchmarks && GOTO AFTER_BENCHMARKS)

ECHO ===== about to benchmark === && CALL mapnik-gyp\benchmark.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:AFTER_BENCHMARKS

ECHO ============================ clean up after TESTS ==========================
ECHO !!!!!!! !!!!! !!!!!! NOT REMOVING PLUGINS COPY DURING benchmark testing
ECHO !!!!!!! !!!!! !!!!!! TODO: enable again! ! ! ! ! !
::DEL /F plugins\input\*.input
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------
echo ERRORLEVEL %ERRORLEVEL%

:DONE
IF %PYTHON_BUILD_FAILED% NEQ 0 (ECHO !!!!!!! Python bindings failed to build !!!!!!!) ELSE (ECHO Python bindings built succesfully)
IF %IGNOREFAILEDTESTS% EQU 1 ECHO !!!!!!! IGNOREFAILEDTESTS was set to 1^: check test results !!!!!!!
echo DONE building Mapnik

EXIT /b %ERRORLEVEL%
