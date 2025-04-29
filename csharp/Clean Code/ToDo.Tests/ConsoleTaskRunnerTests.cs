using Moq;
using Moq.Protected;

namespace ToDo.Tests;

public class ConsoleTaskRunnerTests : IDisposable
{
    private static readonly string TestTaskName = "task";
    private static readonly string TestTaskIndexZero = "0";

    private readonly Mock<ITaskManager<string>> _mockTaskManager;
    private readonly Mock<ITaskMenu> _mockTaskMenu;
    private readonly Mock<ConsoleTaskRunner> _mockTaskRunner;

    public ConsoleTaskRunnerTests()
    {
        _mockTaskManager = new Mock<ITaskManager<string>>();
        _mockTaskMenu = new Mock<ITaskMenu>();
        _mockTaskRunner = new Mock<ConsoleTaskRunner>(_mockTaskManager.Object, _mockTaskMenu.Object);
    }

    [Fact]
    public void NewTask_ValidName()
    {
        _mockTaskMenu.SetupSequence(menu => menu.GetMenuSelection()).Returns(MenuItem.NewTask).Returns(MenuItem.Exit);
        _mockTaskRunner.Protected().Setup<string>("ReadLine").Returns(TestTaskName);

        _mockTaskRunner.Object.Run();

        _mockTaskManager.Verify(taskManager => taskManager.AddTask(It.IsAny<string>()), Times.AtMostOnce());
    }

    [Fact]
    public void NewTask_InvalidName()
    {
        _mockTaskMenu.SetupSequence(menu => menu.GetMenuSelection()).Returns(MenuItem.NewTask).Returns(MenuItem.Exit);
        _mockTaskRunner.Protected().Setup<string>("ReadLine").Throws(new ArgumentNullException());

        _mockTaskRunner.Object.Run();

        _mockTaskManager.Verify(taskManager => taskManager.AddTask(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public void RemoveTask_InvalidInput()
    {
        _mockTaskMenu.SetupSequence(menu => menu.GetMenuSelection()).Returns(MenuItem.RemoveTask).Returns(MenuItem.Exit);
        _mockTaskRunner.Protected().Setup<string>("ReadLine").Returns(TestTaskName);

        _mockTaskRunner.Object.Run();

        _mockTaskManager.Verify(taskManager => taskManager.RemoveTask(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public void RemoveTask_ValidInput_OutOfRange()
    {
        _mockTaskMenu.SetupSequence(menu => menu.GetMenuSelection()).Returns(MenuItem.RemoveTask).Returns(MenuItem.Exit);
        _mockTaskRunner.Protected().Setup<string>("ReadLine").Returns(TestTaskIndexZero);

        _mockTaskRunner.Object.Run();

        _mockTaskManager.Verify(taskManager => taskManager.RemoveTask(It.IsAny<string>()), Times.AtLeastOnce);
    }

    [Fact]
    public void PerformTask()
    {
        _mockTaskMenu.SetupSequence(menu => menu.GetMenuSelection()).Returns(MenuItem.PerformTasks).Returns(MenuItem.Exit);

        _mockTaskRunner.Object.Run();

        _mockTaskManager.Verify(taskManager => taskManager.PerformTasks(), Times.AtLeastOnce);
    }

    [Fact]
    public void Exit_MenuItem_Selection()
    {
        _mockTaskMenu.Setup(menu => menu.GetMenuSelection()).Returns(MenuItem.Exit);

        _mockTaskRunner.Object.Run();

        _mockTaskMenu.Verify(taskMenu => taskMenu.GetMenuSelection(), Times.Once);
    }

    public void Dispose()
    {
        _mockTaskRunner.Reset();
        _mockTaskMenu.Reset();
    }
}
