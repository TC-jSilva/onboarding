namespace ToDo
{

    /// <summary>
    /// Task Manager API
    /// </summary>
    public interface ITaskManager<T>
    {
        /// <summary>
        /// This method writes all registered tasks names in the console.
        /// </summary>
        public void WriteTasks();

        /// <summary>
        /// This method removes the given task name from the local container if present.
        /// </summary>
        /// <param name="taskId">The task identifier/name.</param>
        public void RemoveTask(T taskId);

        /// <summary>
        /// This method register the given task name to the local container.
        /// </summary>
        /// <param name="taskId">The task identifier/name.</param>
        public void AddTask(T taskId);

        /// <summary>
        /// This method perform all registered tasks in the local container if any.
        /// </summary>
        public void PerformTasks();
    }
}