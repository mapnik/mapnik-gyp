#r System.Net;
#r System.ServiceProcess;
#load "win-build-downloader.csx"
#load "win-build-7zip-wrapper.csx"
#load "win-build-prepare-postgis.csx"


static string postgisBundleUrl = "http://download.osgeo.org/postgis/windows/pg94/postgis-bundle-pg94-2.2.1x64.zip";
static string postgisBundleExtractDir = "postgis-bundle-pg94-2.2.1x64";
static string postgresServiceName = "postgresql-x64-9.4";
static string postgresInstallDir = @"C:\Program Files\PostgreSQL\9.4";


static bool onAppVeyor = "appveyor".Equals(Environment.GetEnvironmentVariable("USERNAME"));
static bool mimicAppVeyor = "true".Equals(Environment.GetEnvironmentVariable("APPVEYOR"));
static bool runCodeAnalysis = "1".Equals(Environment.GetEnvironmentVariable("RUNCODEANALYSIS"));
static bool packageDebugSymbols = "1".Equals(Environment.GetEnvironmentVariable("PACKAGEDEBUGSYMBOLS"));
static bool ignoreFailedTests = "1".Equals(Environment.GetEnvironmentVariable("IGNOREFAILEDTESTS"));
static bool ignoreFailedVisualTests = "1".Equals(Environment.GetEnvironmentVariable("IGNOREFAILEDVISUALTESTS"));
static bool fastBuild = "1".Equals(Environment.GetEnvironmentVariable("FASTBUILD"));
static bool superFastBuild = "1".Equals(Environment.GetEnvironmentVariable("SUPERFASTBUILD"));
static bool packageDeps = "1".Equals(Environment.GetEnvironmentVariable("PACKAGEDEPS"));
static string mapnikSdkDir = Path.Combine(Environment.CurrentDirectory, "mapnik-sdk");

Console.WriteLine(new { onAppVeyor });
Console.WriteLine(new { mimicAppVeyor });
Console.WriteLine(new { runCodeAnalysis });
Console.WriteLine(new { packageDebugSymbols });
Console.WriteLine(new { ignoreFailedTests });
Console.WriteLine(new { ignoreFailedVisualTests });
Console.WriteLine(new { fastBuild });
Console.WriteLine(new { superFastBuild });
Console.WriteLine(new { packageDeps });
Console.WriteLine(new { mapnikSdkDir });

private static SevenZipWrapper sz = new SevenZipWrapper(Environment.CurrentDirectory);

private static bool doConfigure()
{
    Console.WriteLine("configuring....");
    if (!onAppVeyor)
    {
        Postgres pg = new Postgres(postgresServiceName, postgresInstallDir);
        if (!Downloader.Download(postgisBundleUrl, "pgis.zip", false)) { return false; }
        if (!Directory.Exists(postgisBundleExtractDir)) { if (!sz.Extract("pgis.zip")) { return false; } } else { Console.WriteLine("pgis.zip already extracted."); }
        if (!pg.InstallPostGIS()) { return false; }
        if (!pg.Start()) { return false; } //start service after PostGIS has been installed
        if (!pg.InstallPostGISTemplate()) { return false; }
    }
    return true;
}


public static bool doBuild()
{
    Console.WriteLine("building ....");
    return true;
}

if (Env.ScriptArgs.Count < 1)
{
    Console.WriteLine("------------------------------------------------");
    Console.WriteLine("usage: scriptcs win-build.csx -- configure|build");
    Environment.ExitCode = 1;
}
else
{
    string cmd = Env.ScriptArgs[0].ToLower();
    if (cmd.Equals("configure"))
    {
        if (!doConfigure())
        {
            Console.WriteLine("!!!!!!!!!!!!! BUILD FAILED !!!!!!!!!!!");
            Environment.ExitCode = 1;
        }
    }
    else if (cmd.Equals("build"))
    {
        if (!doBuild())
        {
            Console.WriteLine("!!!!!!!!!!!!! BUILD FAILED !!!!!!!!!!!");
            Environment.ExitCode = 1;
        }
    }
    else
    {
        Console.WriteLine("unknown command: [{0}]", cmd);
        Environment.ExitCode = 1;
    }
}

Console.WriteLine("finished");
Environment.Exit(Environment.ExitCode);
