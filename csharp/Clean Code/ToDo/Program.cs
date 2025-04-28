using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

namespace ToDo
{

    /// <summary>
    /// Main Program to interact with a Task Manager.
    /// </summary>
    internal class Program
    {
        private static readonly string TaskInNameToOpMssg = "Enter the name of the task to {0}: ";
        private static readonly string TaskOperatonAddMssg = "add";
        private static readonly string TaskOperatonRemoveMssg = "remove";
        private static readonly string TaskDelimiterMssg = "----------------------------------------";
        private static readonly string TaskInErrorMssg = "Not a valid input.";
        private static readonly Regex OnlyDigitsRegex = new Regex(@"^\d+$");

        /// <summary>
        /// Program entry point.
        /// </summary>
        static void Main(string[] args)
        {
            ITaskManager<string> taskManager = new IndexedTaskManager<string>();
            TaskMenu.MenuItem menuSelection = TaskMenu.MenuItem.Exit;
            do
            {
                // Show menu options
                Console.WriteLine(TaskDelimiterMssg);
                TaskMenu.WriteMenuOptions();
                // Get user selection
                menuSelection = TaskMenu.GetMenuSelection();
                try
                {
                    switch (menuSelection)
                    {
                        case TaskMenu.MenuItem.NewTask:
                            {
                                // Add new task
                                Console.WriteLine(TaskInNameToOpMssg, TaskOperatonAddMssg);
                                taskManager.AddTask(ReadLine());
                                Console.WriteLine(TaskDelimiterMssg);
                                break;
                            }

                        case TaskMenu.MenuItem.RemoveTask:
                            {
                                // Show current tasks
                                Console.WriteLine(TaskInNameToOpMssg, TaskOperatonRemoveMssg);
                                taskManager.WriteTasks();
                                Console.WriteLine(TaskDelimiterMssg);
                                // Remove task
                                AttemptRemoveTask(index => taskManager.RemoveTask(index));
                                break;
                            }
                        case TaskMenu.MenuItem.PerformTasks:
                            {
                                // Perform current tasks
                                Console.WriteLine(TaskDelimiterMssg);
                                taskManager.PerformTasks();
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
            } while (menuSelection != TaskMenu.MenuItem.Exit);
        }

        /// <summary>
        /// Attempt to remove a task from the container.
        /// </summary>
        /// <param name="callBack"
        /// Task Manager method reference.
        /// </param>
        private static void AttemptRemoveTask(Action<string> callBack)
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

        /// <summary>
        /// Read a line from the console.
        /// </summary>
        /// <exception cref="ArgumentNullException">
        /// Thrown when the console input is null.
        /// </exception>
        private static string ReadLine()
        {
            return Console.ReadLine() ?? throw new ArgumentNullException(TaskInErrorMssg);
        }

    }
}
