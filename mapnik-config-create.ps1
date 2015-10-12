$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine

$major='A'
$minor='A'
$patch='A'
$version='A'
$version_number='A'

Write-Host reading mapnik version
Get-Content .\mapnik-sdk\include\mapnik\version.hpp |
    foreach { 
        if ($_ -match "#define MAPNIK_MAJOR_VERSION"){ $major = $_.split()[-1] }
        elseif ($_ -match "#define MAPNIK_MINOR_VERSION"){ $minor = $_.split()[-1] }
        elseif ($_ -match "#define MAPNIK_PATCH_VERSION"){ $patch = $_.split()[-1] }
    }

$version = "$major.$minor.$patch"
#multiplication: number first! -> PS converts string/number automatically
$version_number = "{0}" -f ((100000*$major) + (100*$minor) + (1*$patch))

Write-Host version: $version
Write-Host version_number: $version_number


Write-Host looking for dependency libraries
$dep_libs = Get-ChildItem .\mapnik-sdk\lib -Filter "*.lib" -Name
$dep_libs += 'ws2_32.lib'


Write-Host creating mapnik-config.bat
(Get-Content .\mapnik-config.bat.template).
Replace('{{MAPNIK_VERSION}}', $version).
Replace('{{MAPNIK_VERSION_NUMBER}}', $version_number). 
Replace('{{BOOST_VERSION}}', $env:BOOST_VERSION).
Replace('{{BOOST_TOOLSET}}', $env:TOOLS_VERSION.Replace('.','')).
Replace('{{BOOST_COMPILER}}', $env:TOOLS_VERSION). 
Replace('{{DEP_LIBS}}', ($dep_libs -Join ' ')). 
Replace('{{GIT_DESCRIBE}}', $env:MAPNIK_GIT_DESCRIBE). 
Replace('{{GIT_REVISION}}', $env:MAPNIK_GIT_REVISION) | 
Set-Content .\mapnik-config.bat

Write-Host done creating mapnik-config.bat
