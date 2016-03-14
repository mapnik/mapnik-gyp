using System.Diagnostics;

public class SevenZipWrapper
{

    public SevenZipWrapper(string cwd)
    {
        //TODO check if 7z is available
        _Cwd = cwd;
    }

    private string _Cwd;

    public bool Zip() { Console.WriteLine("not implemented"); return false; }

    public bool Extract(
    string archive
    , string destination = ""
  )
    {
        StringBuilder msgStdOut = new StringBuilder();
        StringBuilder msgStdErr = new StringBuilder();

        try
        {
            string cmd = string.Format(
              "7z -y x \"{0}\" {1}"
              , archive
              , string.IsNullOrWhiteSpace(destination) ? "" : "-o\"" + destination + "\""
             );
            Console.WriteLine(
              "Extracting : {1}{0}to         : {2}"
              , Environment.NewLine
              , archive
              , destination
             );
            Console.WriteLine(cmd);
            using (Process p = new Process())
            {
                p.StartInfo = new ProcessStartInfo("cmd", @"/c """ + cmd + "\"")
                {
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    WorkingDirectory = _Cwd,
                    StandardOutputEncoding = Encoding.UTF8,
                    StandardErrorEncoding = Encoding.UTF8
                };

                p.OutputDataReceived += (sender, e) =>
                {
                    if (e.Data != null)
                    {
                        msgStdOut.AppendLine(e.Data);
                    }
                };
                p.ErrorDataReceived += (sender, e) =>
                {
                    if (e.Data != null)
                    {
                        msgStdErr.AppendLine(e.Data);
                    }
                };

                p.Start();
                p.BeginOutputReadLine();
                p.BeginErrorReadLine();
                p.WaitForExit();

                if (0 != p.ExitCode)
                {
                    //display verbose output only after error
                    Console.WriteLine(msgStdOut.ToString());
                    Console.WriteLine(msgStdErr.ToString());
                    return false;
                }

                return true;
            }
        }
        catch (Exception ex)
        {
            //display verbose output only after error
            Console.WriteLine(msgStdOut.ToString());
            Console.WriteLine(msgStdErr.ToString());
            Console.WriteLine(ex.Message);
            return false;
        }
        finally
        {
            // Console.WriteLine(msgStdOut.ToString());
            // Console.WriteLine(msgStdErr.ToString());
        }
    }
}
