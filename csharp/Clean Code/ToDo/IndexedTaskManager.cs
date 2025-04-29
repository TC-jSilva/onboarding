namespace ToDo;

/// <summary>
/// Task Manager API implementation using a List as a local container.
/// </summary>
public class IndexedTaskManager<T> : ITaskManager<T>
{
    private static readonly string TaskNameOperationMssg = "Task {0} successfully {1}";
    private static readonly string TaskOpAddedMssg = "registered";
    private static readonly string TaskOpDeletedMssg = "deleted";
    private static readonly string TaskOpPerformErrorMssg = "There are no tasks to perform";

    private readonly IList<T> _tasks;

    /// <summary>
    /// Default IndexedTaskManager constructor.
    /// </summary>
    public IndexedTaskManager()
    {
        _tasks = [];
    }

    /// <summary>
    /// This method writes all registered tasks names in the console.
    /// </summary>
    public void WriteTasks()
    {
        for (int i = 1; i <= _tasks.Count; i++)
        {
            Console.WriteLine((i) + ". " + _tasks[i - 1]);
        }
    }

    /// <summary>
    /// This method removes the task at the given index from the local container if present.
    /// </summary>
    /// <param name="taskIndex">The task index.</param>
    public void RemoveTask(T taskIndex)
    {
        // Remove one position to make it a zero-based index
        int indexToRemove = Convert.ToInt32(taskIndex) - 1;
        // Verify indexToRemove is in range
        if (indexToRemove >= 0 && indexToRemove < _tasks.Count)
        {
            T task = _tasks[indexToRemove];
            // Remove task from the list at the given index
            _tasks.RemoveAt(indexToRemove);
            Console.WriteLine(TaskNameOperationMssg, task, TaskOpDeletedMssg);
        }
    }

    /// <summary>
    /// This method register the given task name to the local container.
    /// </summary>
    /// <param name="taskId">The task identifier/name.</param>
    public void AddTask(T taskId)
    {
        // Add new task identifier to the list
        _tasks.Add(taskId);
        Console.WriteLine(TaskNameOperationMssg, taskId, TaskOpAddedMssg);
    }

    /// <summary>
    /// This method perform all registered tasks in the local container if any.
    /// </summary>
    public void PerformTasks()
    {
        if (_tasks.Count == 0)
        {
            Console.WriteLine(TaskOpPerformErrorMssg);
        }
        else
        {
            // Write tasks in console
            WriteTasks();
        }
    }

}
