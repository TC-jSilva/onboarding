
using System.Text.RegularExpressions;

namespace ToDo;

public class ConsoleTaskRunner : ITaskRunner
{
    private static readonly string TaskInNameToOpMssg = "Enter the name of the task to {0}: ";
    private static readonly string TaskOperatonAddMssg = "add";
    private static readonly string TaskOperatonRemoveMssg = "remove";
    private static readonly string TaskDelimiterMssg = "----------------------------------------";
    private static readonly string TaskInErrorMssg = "Not a valid input.";
    private static readonly Regex OnlyDigitsRegex = new Regex(@"^\d+$");

    private readonly ITaskManager<string> _taskManager;
    private readonly ITaskMenu _taskMenu;

    /// <summary>
    /// Default ConsoleTaskRunner constructor.
    /// </summary>
    public ConsoleTaskRunner(ITaskManager<string> taskManager, ITaskMenu taskMenu)
    {
        _taskManager = taskManager;
        _taskMenu = taskMenu;
    }

    /// <summary>
    /// Method to execute the Task Manager program console interfaced.
    /// </summary>
    public void Run()
    {

        MenuItem menuSelection = MenuItem.Exit;
        do
        {
            // Show menu options
            Console.WriteLine(TaskDelimiterMssg);
            _taskMenu.WriteMenuOptions();
            // Get user selection
            menuSelection = _taskMenu.GetMenuSelection();
            try
            {
                switch (menuSelection)
                {
                    case MenuItem.NewTask:
                        {
                            // Add new task
                            Console.WriteLine(TaskInNameToOpMssg, TaskOperatonAddMssg);
                            _taskManager.AddTask(ReadLine());
                            Console.WriteLine(TaskDelimiterMssg);
                            break;
                        }

                    case MenuItem.RemoveTask:
                        {
                            // Show current tasks
                            Console.WriteLine(TaskInNameToOpMssg, TaskOperatonRemoveMssg);
                            _taskManager.WriteTasks();
                            Console.WriteLine(TaskDelimiterMssg);
                            // Remove task
                            AttemptRemoveTask(index => _taskManager.RemoveTask(index));
                            break;
                        }
                    case MenuItem.PerformTasks:
                        {
                            // Perform current tasks
                            Console.WriteLine(TaskDelimiterMssg);
                            _taskManager.PerformTasks();
                            Console.WriteLine(TaskDelimiterMssg);
                            break;
                        }
                    default:
                        {
                            // Fisnish execution
                            break;
                        }
                }
            }
            catch (ArgumentException argException)
            {
                // Handle invalid inputs and continue execution
                Console.WriteLine(argException.Message);
            }
        } while (menuSelection != MenuItem.Exit);
    }

    /// <summary>
    /// Read a line from the console.
    /// </summary>
    /// <exception cref="ArgumentNullException">
    /// Thrown when the console input is null.
    /// </exception>
    protected virtual string ReadLine()
    {
        return Console.ReadLine() ?? throw new ArgumentNullException(TaskInErrorMssg);
    }

    /// <summary>
    /// Attempt to remove a task from the container.
    /// </summary>
    /// <param name="callBack"
    /// Task Manager method reference.
    /// </param>
    private void AttemptRemoveTask(Action<string> callBack)
    {
        string index = ReadLine();
        if (OnlyDigitsRegex.IsMatch(index))
        {
            callBack(index);
        }
        else
        {
            throw new ArgumentNullException(TaskInErrorMssg);
        }
    }

}
