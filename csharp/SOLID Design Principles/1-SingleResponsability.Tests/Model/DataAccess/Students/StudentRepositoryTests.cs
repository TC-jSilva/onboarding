namespace SingleResponsability;

public class StudentRepositoryTests
{
    [Fact]
    public void GetAll_NotNull_Empty()
    {
        var students = StudentRepository.Instance.GetAll();
        Assert.NotNull(students);
        Assert.Empty(students);
    }

    [Fact]
    public void InitData_GetAll_NotNull_NotEmpty() {
        IList<Student> students = [
            new Student(1, "Pepito Pérez", [3, 4.5]),
            new Student(2, "Mariana Lopera", [4, 5]),
            new Student(3, "José Molina", [2, 3])];
        var copy = StudentRepository.Instance.InitData(students).GetAll();
        Assert.NotNull(copy);
        Assert.NotEmpty(copy);
    }
}
