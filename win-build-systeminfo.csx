using System.Management;

public static class SystemInfo
{

    public static void Info()
    {
        Console.WriteLine("-------------------sys info----------------");
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(
              "root\\CIMV2",
              "SELECT * FROM Win32_ComputerSystem"
             );

            foreach (ManagementObject queryObj in searcher.Get())
            {
                Console.WriteLine("TotalPhysicalMemory       : {0}GB", ((UInt64)queryObj["TotalPhysicalMemory"])/(1024*1024*1024));
                Console.WriteLine("NumberOfProcessors        : {0}", queryObj["NumberOfProcessors"]);
                Console.WriteLine("NumberOfLogicalProcessors : {0}", queryObj["NumberOfLogicalProcessors"]);
            }
            foreach (var drive in DriveInfo.GetDrives())
            {
                if (!drive.IsReady)
                {
                    Console.WriteLine("{0} not ready", drive.Name);
                }
                else
                {
                    Console.WriteLine("{0}\ttotalsize:{1}GB\tfreeavail:{2}GB\tfreetotal:{3}GB"
                    , drive.Name
                    , drive.TotalSize / (1024 * 1024 * 1024)
                    , drive.AvailableFreeSpace / (1024 * 1024 * 1024)
                    , drive.TotalFreeSpace / (1024 * 1024 * 1024)
                    );
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
        finally
        {
            Console.WriteLine("-------------------sys info----------------" + Environment.NewLine);
        }
    }




}