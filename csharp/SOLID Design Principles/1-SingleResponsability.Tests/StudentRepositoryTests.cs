namespace SingleResponsability.Tests;

public class StudentRepositoryTests
{
    [Fact]
    public void GetAll_NotNull_NotEmpty()
    {
        var students = StudentRepository.Instance.GetAll();
        Assert.NotNull(students);
        Assert.NotEmpty(students);
    }
}
