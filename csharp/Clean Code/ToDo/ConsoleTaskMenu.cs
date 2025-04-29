namespace ToDo;

/// <summary>
/// Available Task Menu Items.
/// </summary>
public enum MenuItem
{
    Unkown,
    NewTask,
    RemoveTask,
    PerformTasks,
    Exit
}

/// <summary>
/// This class provides menu options to perform operations over a task.
/// </summary>
public class ConsoleTaskMenu : ITaskMenu
{

    /// <summary>
    /// Write in console available menu options.
    /// </summary>
    public void WriteMenuOptions()
    {
        Console.WriteLine("Enter the option to perform: ");
        Console.WriteLine("1. New task");
        Console.WriteLine("2. Remove task");
        Console.WriteLine("3. Perform tasks");
        Console.WriteLine("4. Exit");
    }


    /// <summary>
    /// Retrieve a MenuItem from console input.
    /// </summary>
    public MenuItem GetMenuSelection()
    {
        try
        {
            string? selection = Console.ReadLine();
            // when selection is null, then return Exit
            return Enum.Parse<MenuItem>(selection ?? MenuItem.Exit.ToString());
        }
        catch
        {
            // Return Exit, when there is an exception at parsing the input
            return MenuItem.Exit;
        }
    }
}
