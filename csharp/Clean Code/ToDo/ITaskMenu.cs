namespace ToDo
{
    /// <summary>
    /// Interface to execute the Task Manager menu.
    /// </summary>
    public interface ITaskMenu
    {
        /// <summary>
        /// Write available menu options to an output.
        /// </summary>
        public void WriteMenuOptions();

        /// <summary>
        /// Retrieve a MenuItem from an input.
        /// </summary>
        public MenuItem GetMenuSelection();
    }
}