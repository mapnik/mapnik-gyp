using System.Diagnostics;
using System.ServiceProcess;

public class Postgres
{

    public Postgres(string servicename, string installDir)
    {
        _ServiceName = servicename;
        _InstallDir = installDir;
    }

    private string _ServiceName;
    private string _InstallDir;
    public bool Start()
    {
        try
        {
            bool running = Process.GetProcessesByName("postgres").Length > 0;
            if (running)
            {
                Console.WriteLine("Postgres already running");
            }
            else
            {
                Console.WriteLine("Postgres not running, trying to start [{0}]...", _ServiceName);
                if (!startService(45)) { return false; }
            }

            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }
    }

    public bool InstallPostGIS()
    {
        try
        {
            Console.WriteLine("TODO INSTALL POSTGIS");
            //_InstallDir + "psql"
            //TODO check if files are already there
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }
    }

    public bool InstallPostGISTemplate()
    {
        try
        {
            Console.WriteLine("TODO INSTALL POSTGIS TEMPLATE AND CREATE EXTENSION");
            //_InstallDir + "psql"
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }
    }

    private bool startService(int timeoutSecs)
    {
        try
        {
            TimeSpan timeout = TimeSpan.FromSeconds(timeoutSecs);
            ServiceController service = new ServiceController(_ServiceName);
            service.Start();
            service.WaitForStatus(ServiceControllerStatus.Running, timeout);
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }
    }
}
