public static void WriteError(string msg, params object[] args) {
  Console.ForegroundColor = ConsoleColor.Red;
  Console.WriteLine(msg, args);
  Console.ResetColor();
}

public static void WriteWarning(string msg, params object[] args) {
  Console.ForegroundColor = ConsoleColor.Yellow;
  Console.WriteLine(msg, args);
  Console.ResetColor();
}
