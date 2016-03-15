using System.Threading;
public static class Deleter
{

    public static bool Delete(string[] dirs)
    {
        foreach (var dir in dirs)
        {
            if (!Directory.Exists(dir))
            {
                Console.WriteLine("does not exist [{0}]", dir);
                continue;
            }
            Console.WriteLine("removing [{0}]", dir);
            if(!DeleteFilesAndFoldersRecursively(dir)){
                return false;
            }
            Console.WriteLine("removed [{0}]", dir);
        }

        return true;
    }

    private static bool DeleteFilesAndFoldersRecursively(string target_dir)
    {

        bool fileSuccess = true;
        foreach (string file in Directory.GetFiles(target_dir))
        {
            if (!deleteFile(file))
            {
                fileSuccess = false;
            }
        }

        bool dirSuccess = true;
        foreach (string subDir in Directory.GetDirectories(target_dir))
        {
            bool tmpSuccess = DeleteFilesAndFoldersRecursively(subDir);
            if (!tmpSuccess) { dirSuccess = false; }
        }

        // This makes the difference between whether it works or not.
        Thread.Sleep(10);

        if (!deleteDir(target_dir))
        {
            dirSuccess = false;
        }

        return (fileSuccess && dirSuccess);
    }


    private static bool deleteFile(string file)
    {
        for (int i = 0; i < 3; i++)
        {
            try
            {
                FileInfo f = new FileInfo(file);
                f.Attributes = f.Attributes & ~(FileAttributes.Archive | FileAttributes.ReadOnly | FileAttributes.Hidden);
                f.Delete();
                return true;
            }
            catch (Exception e)
            {
                Thread.Sleep(100);
            }
        }

        return false;
    }


    private static bool deleteDir(string dir)
    {

        for (int i = 0; i < 3; i++)
        {
            try
            {
                DirectoryInfo d = new DirectoryInfo(dir);
                d.Attributes = d.Attributes & ~(FileAttributes.Archive | FileAttributes.ReadOnly | FileAttributes.Hidden);
                d.Delete();
                return true;
            }
            catch (Exception e)
            {
                Thread.Sleep(100);
            }
        }

        return false;
    }

}