


static bool verbose = "1".Equals(Environment.GetEnvironmentVariable("VERBOSE"));
static string platform = Environment.GetEnvironmentVariable("PLATFORM").ToLower();
static string buildType = Environment.GetEnvironmentVariable("BUILD_TYPE");
static bool isX64 = "x64".Equals(platform);
static string buildPlatform = isX64 ? "x64" : "Win32";
static bool onAppVeyor = "appveyor".Equals(Environment.GetEnvironmentVariable("USERNAME"));
static bool envAppVeyor = "true".Equals(Environment.GetEnvironmentVariable("APPVEYOR"));
static bool runCodeAnalysis = "1".Equals(Environment.GetEnvironmentVariable("RUNCODEANALYSIS"));
static bool packageDebugSymbols = "1".Equals(Environment.GetEnvironmentVariable("PACKAGEDEBUGSYMBOLS"));
static bool ignoreFailedTests = "1".Equals(Environment.GetEnvironmentVariable("IGNOREFAILEDTESTS"));
static bool ignoreFailedVisualTests = "1".Equals(Environment.GetEnvironmentVariable("IGNOREFAILEDVISUALTESTS"));
static bool fastBuild = "1".Equals(Environment.GetEnvironmentVariable("FASTBUILD"));
static bool superFastBuild = "1".Equals(Environment.GetEnvironmentVariable("SUPERFASTBUILD"));
static bool packageDeps = "1".Equals(Environment.GetEnvironmentVariable("PACKAGEDEPS"));
static string mapnikSdkDir = Path.Combine(Environment.CurrentDirectory, "mapnik-sdk");
static string rootDir = Environment.GetEnvironmentVariable("ROOTDIR");
static string pythonDir = isX64 ? Path.Combine(rootDir, "tmp-bin", "python2") : Path.Combine(rootDir, "tmp-bin", "python2-x86-32");
static string localDepsDir = Environment.GetEnvironmentVariable("PKGDIR");
static string harfbuzzDirSrc = Path.Combine(localDepsDir, "harfbuzz", "src");
static string sdkIncludeHarfbuzz = Path.Combine(mapnikSdkDir, "include", "harfbuzz");
static string gdalVersionFile = Environment.GetEnvironmentVariable("GDAL_VERSION_FILE");
static string icuVersion = Environment.GetEnvironmentVariable("ICU_VERSION");
static string icuPathPostfix = isX64 ? "64" : "";
static string icuFilePostfix = buildType.ToLower().Equals("debug") ? "d" : "";
static string libpqFilePostfix = buildType.ToLower().Equals("debug") ? "d" : "";
static string webpPlatform = Environment.GetEnvironmentVariable("WEBP_PLATFORM");

static string ogrPath = Path.Combine(localDepsDir, "gdal", "ogr");
static string gcorePath = Path.Combine(localDepsDir, "gdal", "gcore");
static string gdalPortPath = Path.Combine(localDepsDir, "gdal", "port");
static string zlibPathTmp = Path.Combine(
  localDepsDir
  , "zlib"
  , "contrib"
  , "vstudio"
  , "vc11"
  , platform
);
static string zlibPath =
  buildType.ToLower().Equals("release")
  ? Path.Combine(zlibPathTmp, "ZlibDllReleaseWithoutAsm")
  : Path.Combine(zlibPathTmp, "ZlibDll");
static string webpFileSuffix = buildType.ToLower().Equals("debug") ? "_debug" : "";
static string webpPath = Path.Combine(localDepsDir, "webp", "output", buildType + "-dynamic", webpPlatform);
static string libpngPath = Path.Combine(
  localDepsDir
  , "libpng"
  , "projects"
  , "vstudio"
  , isX64 ? "x64" : ""
  , buildType
);

static string protobufPath = Path.Combine(
  localDepsDir
  , "protobuf"
  , "vsprojects"
  , isX64 ? buildPlatform : ""
  , buildType
);



if (onAppVeyor)
{
    envAppVeyor = true;
    fastBuild = true;
    superFastBuild = true;
}

if (superFastBuild)
{
    fastBuild = true;
}

Console.WriteLine("---------------parameters----------------");
Console.WriteLine(new { depsUrl });
Console.WriteLine(new { onAppVeyor });
Console.WriteLine(new { envAppVeyor });
Console.WriteLine(new { verbose });
Console.WriteLine(new { platform });
Console.WriteLine(new { isX64 });
Console.WriteLine(new { buildPlatform });
Console.WriteLine(new { buildType });
Console.WriteLine(new { runCodeAnalysis });
Console.WriteLine(new { packageDebugSymbols });
Console.WriteLine(new { ignoreFailedTests });
Console.WriteLine(new { ignoreFailedVisualTests });
Console.WriteLine(new { fastBuild });
Console.WriteLine(new { superFastBuild });
Console.WriteLine(new { packageDeps });
Console.WriteLine(new { mapnikSdkDir });
Console.WriteLine(new { rootDir });
Console.WriteLine(new { pythonDir });
Console.WriteLine(new { localDepsDir });
Console.WriteLine(new { harfbuzzDirSrc });
Console.WriteLine(new { sdkIncludeHarfbuzz });
Console.WriteLine(new { gdalVersionFile });
Console.WriteLine(new { icuVersion });
Console.WriteLine(new { icuPathPostfix });
Console.WriteLine(new { icuFilePostfix });
Console.WriteLine(new { libpqFilePostfix });
Console.WriteLine(new { webpPlatform });
Console.WriteLine(new { webpFileSuffix });
Console.WriteLine(new { webpPath });
Console.WriteLine(new { libpngPath });
Console.WriteLine(new { protobufPath });
Console.WriteLine(new { ogrPath });
Console.WriteLine(new { gcorePath });
Console.WriteLine(new { gdalPortPath });
Console.WriteLine(new { zlibPath });
Console.WriteLine("---------------parameters----------------" + Environment.NewLine);

public class Dependency
{
    public Dependency() { recursive = true; }
    public string from { get; set; }
    public string to { get; set; }
    public bool destIsDir { get; set; }
    public bool recursive { get; set; }
}


public static Dictionary<string, List<Dependency>> dependencies = new Dictionary<string, List<Dependency>>()
{
  {
    "Python headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(pythonDir,"include"), to=Path.Combine(mapnikSdkDir,"include")},
      new Dependency(){from=Path.Combine(pythonDir,"libs", "python27.lib"), to=Path.Combine(mapnikSdkDir, "lib"), destIsDir=true}
    }
  },
  {
    "harfbuzz headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"harfbuzz-build", "harfbuzz", "hb-version.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-shape-plan.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-shape.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-set.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-ft.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-buffer.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-unicode.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-common.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-blob.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-font.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-face.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-deprecated.h"), to=sdkIncludeHarfbuzz, destIsDir=true}
    }
  },
  {
    "boost headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"boost", "boost"), to=Path.Combine(mapnikSdkDir,"include", "boost")}
    }
  },
  {
    "icu headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "include", "unicode"), to=Path.Combine(mapnikSdkDir,"include", "unicode")}
    }
  },
  {
    "freetype headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"freetype", "include"), to=Path.Combine(mapnikSdkDir,"include", "freetype2")}
    }
  },
  {
    "zlib headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"zlib", "zlib.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"zlib", "zconf.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "png headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"libpng", "png.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libpng", "pnglibconf.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libpng", "pngconf.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "libjpegturbo headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "jpeglib.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "jmorecfg.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "build", "jconfig.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "build", "jconfigint.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "webp headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"webp", "src", "webp"), to=Path.Combine(mapnikSdkDir,"include", "webp")}
    }
  },
  {
    "proj4 headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"proj", "src", "proj_api.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "libtiff headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "tiff.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "tiffvers.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "tiffconf.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "tiffio.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
    }
  },
  {
    "cairo headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "cairo-version.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-features.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-deprecated.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-svg.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-svg-surface-private.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-pdf.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-ft.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", "cairo-ps.h"), to=Path.Combine(mapnikSdkDir,"include", "cairo"), destIsDir=true},
    }
  },
  {
    "protobuf headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"protobuf", "src", "google"), to=Path.Combine(mapnikSdkDir,"include", "google")}
    }
  },
  {
    "postgres headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"postgresql", "src", "interfaces", "libpq", "libpq-fe.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"postgresql", "src", "include", "postgres_ext.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"postgresql", "src", "include", "pg_config_ext.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "sqlite headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"sqlite", "sqlite3.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true}
    }
  },
  {
    "gdal headers",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(ogrPath, "ogr_api.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_feature.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_spatialref.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_geometry.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_core.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_featurestyle.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogrsf_frmts", "ogrsf_frmts.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(ogrPath, "ogr_srs_api.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gcorePath, "gdal_priv.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gcorePath, "gdal_frmts.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gcorePath, "gdal.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gcorePath, "gdal_version.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_minixml.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_atomic_ops.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_string.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_conv.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_vsi.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_multiproc.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_virtualmem.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_error.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_progress.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_port.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
      new Dependency(){from=Path.Combine(gdalPortPath, "cpl_config.h"), to=Path.Combine(mapnikSdkDir,"include"), destIsDir=true},
    }
  },
  {
    "mapbox variant headers",
    new List<Dependency>(){
      new Dependency(){
        from=Path.Combine(Environment.CurrentDirectory,"..", "deps", "mapbox", "variant", "*.hpp"),
        to=Path.Combine(mapnikSdkDir,"include", "mapbox", "variant"),
        recursive=false
        }
    }
  },
  {
    "libraries",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"harfbuzz-build", "harfbuzz.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"freetype", "freetype.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "lib" + icuPathPostfix, "icuuc" + icuFilePostfix + ".lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "lib" + icuPathPostfix, "icuin" + icuFilePostfix + ".lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "lib" + icuPathPostfix, "icudt.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "bin" + icuPathPostfix, "icuuc" + icuVersion + icuFilePostfix + ".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "bin" + icuPathPostfix, "icuin" + icuVersion + icuFilePostfix + ".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "bin" + icuPathPostfix, "icudt" + icuVersion + ".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "libtiff.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libtiff", "libtiff", "libtiff_i.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"zlib", "zlib.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(zlibPath, "zlibwapi.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(zlibPath, "zlibwapi.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(webpPath,"lib", "libwebp"+ webpFileSuffix +"_dll.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(webpPath,"bin", "libwebp"+ webpFileSuffix+".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(libpngPath,"libpng16.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(libpngPath,"libpng16.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "build", "sharedlib", buildType, "jpeg.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"libjpegturbo", "build", "sharedlib", buildType, "jpeg62.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", buildType, "cairo-static.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", buildType, "cairo.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"cairo", "src", buildType, "cairo.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"boost", "stage", "lib", "*.*"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(protobufPath,"libprotobuf-lite.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(protobufPath,"protoc.exe"), to=Path.Combine(mapnikSdkDir,"bin"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"postgresql", "src", "interfaces", "libpq", buildType, "libpq"+ libpqFilePostfix+".lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"postgresql", "src", "interfaces", "libpq", buildType, "libpq"+ libpqFilePostfix+".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"sqlite", "sqlite3.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"gdal", "gdal_i.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"gdal", "gdal" + gdalVersionFile + ".dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"expat", "win32", "bin", buildType, "libexpat.lib"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
      new Dependency(){from=Path.Combine(localDepsDir,"expat", "win32", "bin", buildType, "libexpat.dll"), to=Path.Combine(mapnikSdkDir,"lib"), destIsDir=true},
    }
  },
  {
    "additional data files",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"proj", "nad"), to=Path.Combine(mapnikSdkDir,"share", "proj")},
      new Dependency(){from=Path.Combine(localDepsDir,"gdal", "data"), to=Path.Combine(mapnikSdkDir,"share", "gdal")},
    }
  },
};
