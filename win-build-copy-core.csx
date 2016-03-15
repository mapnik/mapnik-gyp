using System.Management;

public static class CopyCore
{

    public static bool Copy(string from, string to, bool destIsDir)
    {
        try
        {
            FileAttributes attr = File.GetAttributes(from);
            bool srcIsDir = attr.HasFlag(FileAttributes.Directory);
            if (srcIsDir)
            {
                if (!DirectoryCopy(from, to)) { return false; }
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

    private static bool DirectoryCopy(string sourceDirName, string destDirName, bool copySubDirs = true)
    {
        try
        {
            DirectoryInfo dir = new DirectoryInfo(sourceDirName);
            DirectoryInfo[] dirs = dir.GetDirectories();
            if (!Directory.Exists(destDirName))
            {
                Directory.CreateDirectory(destDirName);
            }

            FileInfo[] files = dir.GetFiles();
            foreach (FileInfo file in files)
            {
                file.CopyTo(Path.Combine(destDirName, file.Name), true);
            }

            if (copySubDirs)
            {
                foreach (DirectoryInfo subdir in dirs)
                {
                    string temppath = Path.Combine(destDirName, subdir.Name);
                    if (DirectoryCopy(subdir.FullName, temppath, copySubDirs))
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