using System.Management;

public static class CopyCore
{

    public static bool Copy(string from, string to, bool destIsDir, bool recursive=true)
    {
        if (verbose)
        {
            Console.WriteLine("copy from:{1}{0}copy to:{2}{0}destIsDir:{3}", Environment.NewLine, from, to, destIsDir);
        }
        try
        {
            string searchPattern = "*.*";
            string src = Path.GetFileName(from);
            if(src.Contains("*") || src.Contains("?")){
                from = Path.GetDirectoryName(from);
                searchPattern = src;
            }
            FileAttributes attr = File.GetAttributes(from);
            bool srcIsDir = attr.HasFlag(FileAttributes.Directory);
            if (verbose) { Console.WriteLine("srcIsDir: {0}", srcIsDir); }
            if (srcIsDir)
            {
                if (!DirectoryCopy(from, to, searchPattern, recursive)) { return false; }
            }
            else
            {
                if (destIsDir)
                {
                    if (!Directory.Exists(to))
                    {
                        Directory.CreateDirectory(to);
                    }
                    to = Path.Combine(to, Path.GetFileName(from));
                }
                FileInfo fi = new FileInfo(from);
                fi.CopyTo(to, true);
                // Console.WriteLine("{0} {1}", srcIsDir ? "dir" : "file", from);
            }
            return true;
        }
        catch (Exception ex)
        {
            WriteError(ex.Message);
            return false;
        }
    }

    private static bool DirectoryCopy(
      string sourceDirName
      , string destDirName
      , string pattern="*.*"
      , bool copySubDirs = true
      )
    {
        try
        {
            DirectoryInfo dir = new DirectoryInfo(sourceDirName);
            DirectoryInfo[] dirs = dir.GetDirectories();
            if (!Directory.Exists(destDirName))
            {
                Directory.CreateDirectory(destDirName);
            }

            FileInfo[] files = dir.GetFiles(pattern);
            foreach (FileInfo file in files)
            {
                file.CopyTo(Path.Combine(destDirName, file.Name), true);
            }

            if (copySubDirs)
            {
                foreach (DirectoryInfo subdir in dirs)
                {
                    string temppath = Path.Combine(destDirName, subdir.Name);
                    if (!DirectoryCopy(subdir.FullName, temppath, pattern))
                    {
                        return false;
                    }
                }
            }

            return true;
        }
        catch (Exception ex)
        {
            WriteError(ex.Message);
            return false;
        }
    }


}