using System.Management;

public static class CopyDeps
{

    public static bool Copy(Dictionary<string, List<Dependency>> deps)
    {
      Console.WriteLine("~~~~~~~~~~~~ copy dependencies ~~~~~~~~~");
        foreach (var depGrp in deps)
        {
            Console.WriteLine("-{0}", depGrp.Key);
            foreach (var dep in depGrp.Value){
                if(!CopyCore.Copy( dep.from, dep.to, dep.destIsDir)){
                  return false;
                }
            }
        }
      Console.WriteLine("~~~~~~~~~~~~ copy dependencies finished ~~" + Environment.NewLine);
        return true;
    }




}