


static string platform = Environment.GetEnvironmentVariable("PLATFORM").ToLower();
static bool isX64 = "x64".Equals(platform);
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
static bool useLocalDeps = "1".Equals(Environment.GetEnvironmentVariable("MAPNIK_USE_LOCAL_DEPS"));
static string rootDir = Environment.GetEnvironmentVariable("ROOTDIR");
static string pythonDir = isX64 ? Path.Combine(rootDir, "tmp-bin", "python2") : Path.Combine(rootDir, "tmp-bin", "python2-x86-32");
static string localDepsDir = Environment.GetEnvironmentVariable("PKGDIR");
static string harfbuzzDirSrc = Path.Combine(localDepsDir, "harfbuzz", "src");
static string sdkIncludeHarfbuzz = Path.Combine(mapnikSdkDir, "include", "harfbuzz");

if (onAppVeyor)
{
    envAppVeyor = true;
    fastBuild = true;
    superFastBuild = true;
    useLocalDeps = false;
}

Console.WriteLine("---------------parameters----------------");
Console.WriteLine(new { depsUrl });
Console.WriteLine(new { onAppVeyor });
Console.WriteLine(new { envAppVeyor });
Console.WriteLine(new { platform });
Console.WriteLine(new { isX64 });
Console.WriteLine(new { runCodeAnalysis });
Console.WriteLine(new { packageDebugSymbols });
Console.WriteLine(new { ignoreFailedTests });
Console.WriteLine(new { ignoreFailedVisualTests });
Console.WriteLine(new { fastBuild });
Console.WriteLine(new { superFastBuild });
Console.WriteLine(new { packageDeps });
Console.WriteLine(new { mapnikSdkDir });
Console.WriteLine(new { useLocalDeps });
Console.WriteLine(new { rootDir });
Console.WriteLine(new { pythonDir });
Console.WriteLine(new { localDepsDir });
Console.WriteLine(new { harfbuzzDirSrc });
Console.WriteLine(new { sdkIncludeHarfbuzz });
Console.WriteLine("---------------parameters----------------" + Environment.NewLine);

public class Dependency
{
    public string from { get; set; }
    public string to { get; set; }
    public bool destIsDir { get; set; }
}

public static Dictionary<string, List<Dependency>> dependencies = new Dictionary<string, List<Dependency>>()
{
  {
    "Python",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(pythonDir,"include"), to=Path.Combine(mapnikSdkDir,"include")},
      new Dependency(){from=Path.Combine(pythonDir,"libs", "python27.lib"), to=Path.Combine(mapnikSdkDir, "lib"), destIsDir=true}
    }
  },
  {
    "harfbuzz",
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
      new Dependency(){from=Path.Combine(harfbuzzDirSrc, "hb-deprecated.h"), to=sdkIncludeHarfbuzz, destIsDir=true},
    }
  },
  {
    "boost",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"boost", "boost"), to=Path.Combine(mapnikSdkDir,"include", "boost")}
    }
  },
  {
    "icu",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"icu", "include", "unicode"), to=Path.Combine(mapnikSdkDir,"include", "unicode")},
    }
  },
  {
    "freetype",
    new List<Dependency>(){
      new Dependency(){from=Path.Combine(localDepsDir,"freetype", "include"), to=Path.Combine(mapnikSdkDir,"include", "freetype2")}
    }
  },
};
