using System.IO;
using System.Net;

public static class Downloader
{

    public static bool Download(string url, string localFile = null, bool overwrite=true)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(localFile))
            {
                localFile = new Uri(url).Segments.Last();
            }
            string localFileFull = Path.GetFullPath(localFile);
            Console.WriteLine(
              "downloading : {1}{0}to          : {2}"
              , Environment.NewLine
              , url
              , localFileFull
            );
            if (File.Exists(localFileFull) && !overwrite)
            {
                Console.WriteLine("skipping, file already downloaded {0}", localFileFull);
                return true;
            }
            using (WebClient wc = new WebClient())
            {
                wc.DownloadFile(url, localFileFull);
            }
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }
    }
}
