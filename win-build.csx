#r System.Management;
#r System.Net;
#r System.ServiceProcess;
#load "win-build-7zip-wrapper.csx"
#load "win-build-copy-core.csx"
#load "win-build-copy-deps.csx"
#load "win-build-deleter.csx"
#load "win-build-downloader.csx"
#load "win-build-pagefile.csx"
#load "win-build-parameters.csx"
#load "win-build-prepare-postgis.csx"
#load "win-build-systeminfo.csx"
#load "win-build-util.csx"


static string depsUrl = string.Format(
  "https://mapbox.s3.amazonaws.com/windows-builds/windows-build-deps/mapnik-win-sdk-binary-deps-{0}.0-{1}.7z"
  , Environment.GetEnvironmentVariable("msvs_toolset")
  , Environment.GetEnvironmentVariable("platform").ToLower()
);
static string postgisBundleUrl = "http://download.osgeo.org/postgis/windows/pg94/postgis-bundle-pg94-2.2.1x64.zip";
static string postgisBundleExtractDir = "postgis-bundle-pg94-2.2.1x64";
static string postgresServiceName = "postgresql-x64-9.4";
static string postgresInstallDir = @"C:\Program Files\PostgreSQL\9.4";
static string[] appveyorDelete = new string[]{
  @"C:\qt"
  , @"C:\Users\appveyor\AppData\Local\Microsoft\Web Platform Installer"
    //, @"C:\Program Files\Microsoft SQL Server"
    //, @"C:\ProgramData\Package Cache"
};
static uint appveyorNewPageFileSize = 18000; //MB

private static SevenZipWrapper sz = new SevenZipWrapper(Environment.CurrentDirectory);

private static bool doConfigure()
{
    Console.WriteLine("configuring....");
    if (onAppVeyor)
    {
        Postgres pg = new Postgres(postgresServiceName, postgresInstallDir);
        if (!pg.Start()) { return false; }
        if (!Deleter.Delete(appveyorDelete)) { return false; }
        if (!PageFileChanger.SetNewSize(appveyorNewPageFileSize)) { return false; }
        if (!Downloader.Download(postgisBundleUrl, "pgis.zip", false)) { return false; }
        if (!Directory.Exists(postgisBundleExtractDir)) { if (!sz.Extract("pgis.zip")) { return false; } } else { Console.WriteLine("pgis.zip already extracted."); }
        if (!pg.InstallPostGIS()) { return false; }
        if (!pg.InstallPostGISTemplate()) { return false; }
    }
    if (fastBuild || superFastBuild)
    {
        if (!Downloader.Download(depsUrl, "deps.7z", false)) { return false; }
        if (!Directory.Exists("mapnik-sdk")) { if (!sz.Extract("deps.7z")) { return false; } } else { Console.WriteLine("mapnik-sdk already extracted."); }
    }
    else
    {
        if (!Deleter.Delete(new string[] { Path.Combine(Environment.CurrentDirectory, "mapnik-sdk") })) { return false; }
        if (!CopyDeps.Copy(dependencies)) { return false; }
    }
    if (packageDeps) { WriteError("!!!TODO: package DEPS!!!"); }
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
    SystemInfo.Info();
    string cmd = Env.ScriptArgs[0].ToLower();
    if (cmd.Equals("configure"))
    {
        if (!doConfigure())
        {
            WriteError("!!!!!!!!!!!!! CONFIGURE FAILED !!!!!!!!!!!");
            Environment.ExitCode = 1;
        }
    }
    else if (cmd.Equals("build"))
    {
        if (!doBuild())
        {
            WriteError("!!!!!!!!!!!!! BUILD FAILED !!!!!!!!!!!");
            Environment.ExitCode = 1;
        }
    }
    else
    {
        WriteError("unknown command: [{0}]", cmd);
        Environment.ExitCode = 1;
    }
}

Console.WriteLine("finished");
Environment.Exit(Environment.ExitCode);
