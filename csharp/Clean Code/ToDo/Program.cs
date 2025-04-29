namespace ToDo;

/// <summary>
/// Main Program to interact with a Task Manager.
/// </summary>
public class Program
{

    /// <summary>
    /// Program entry point.
    /// </summary>
    public static void Main(string[] args)
    {
        ITaskRunner taskRunner = new ConsoleTaskRunner(new IndexedTaskManager<string>(),
            new ConsoleTaskMenu());
        taskRunner.Run();
    }

}

