using System.Management;

public static class PageFileChanger
{

    public static bool SetNewSize(uint newSize)
    {
        if (isAutomatic())
        {
            if (!disableAutomatic()) { return false; }
            //check if still automatic
            if (isAutomatic())
            {
                WriteError("could not deactivate automatic pagefile management");
                return false;
            }
        }
        uint size = getSize();
        if (uint.MaxValue == size)
        {
            WriteError("Could not read current pagefile size.");
            return false;
        }
        if (newSize == size)
        {
            Console.WriteLine("Current size already set to: [{0}]", newSize);
            return true;
        }
        if (!setSize(newSize))
        {
            return false;
        }
        if (newSize != getSize())
        {
            WriteError("Failed to set new pagefile size");
            return false;
        }
        Console.WriteLine("Pagefile size set to: {0}", newSize);
        return true;
    }


    private static bool setSize(uint size)
    {
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(
              "root\\CIMV2",
              "SELECT * FROM Win32_PageFileSetting"
             );

            foreach (ManagementObject queryObj in searcher.Get())
            {
                queryObj["InitialSize"] = size;
                queryObj["MaximumSize"] = size;
                PutOptions putOptions = new PutOptions();
                putOptions.Type = PutType.UpdateOnly;
                queryObj.Put(putOptions);
            }
            return true;
        }
        catch (Exception ex)
        {
            WriteError(ex.Message);
            return false;
        }
    }

    private static uint getSize()
    {
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(
              "root\\CIMV2",
              "SELECT * FROM Win32_PageFileSetting"
             );

            uint size = 0;
            foreach (ManagementObject queryObj in searcher.Get())
            {
                Console.WriteLine("pagefile, InitialSize: {0}", queryObj["InitialSize"]);
                Console.WriteLine("pagefile, MaximumSize: {0}", queryObj["MaximumSize"]);
                size = (uint)queryObj["InitialSize"];
            }
            return size;
        }
        catch (Exception ex)
        {
            WriteError(ex.Message);
            return uint.MaxValue;
        }
    }


    private static bool disableAutomatic()
    {
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(
                  "root\\CIMV2"
                , "SELECT * FROM Win32_ComputerSystem"
                );

            bool isAutomatic = false;
            foreach (ManagementObject queryObj in searcher.Get())
            {
                Console.WriteLine("AutomaticManagedPagefile: {0}", queryObj["AutomaticManagedPagefile"]);
                isAutomatic = (bool)queryObj["AutomaticManagedPagefile"];
                if (!isAutomatic)
                {
                    Console.WriteLine("pagefile management is not automatic");
                }
                else
                {
                    Console.WriteLine("disabling automatic pagefile management");
                    PutOptions putOptions = new PutOptions();
                    putOptions.Type = PutType.UpdateOnly;
                    queryObj["AutomaticManagedPagefile"] = false;
                    try //always get an excepion here, don't know why
                    {
                        queryObj.Put(putOptions);
                    }
                    catch (Exception e)
                    {
                        WriteWarning("caught expected exception: {0}", e);
                    }
                }
            }
            return true;
        }
        catch (Exception ex)
        {
            WriteError(ex.ToString());
            return false;
        }
    }

    private static bool isAutomatic()
    {
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(
                  "root\\CIMV2"
                , "SELECT * FROM Win32_ComputerSystem"
                );

            bool isAutomatic = false;
            foreach (ManagementObject queryObj in searcher.Get())
            {
                isAutomatic = (bool)queryObj["AutomaticManagedPagefile"];
            }
            return isAutomatic;
        }
        catch (Exception ex)
        {
            WriteError(ex.ToString());
            return false;
        }
    }


}