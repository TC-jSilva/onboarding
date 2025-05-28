namespace SingleResponsability;

public class CsvStudentReportTests
{

    [Fact]
    public void BuildData_NotEmptyCollection()
    {
        IList<Student> students = [
        new Student(1, "Pepito Pérez", [3, 4.5]),
        new Student(2, "Mariana Lopera", [4, 5]),
        new Student(3, "José Molina", [2, 3])];
        CsvStudentReport.Instance.Export(students);
    }

    [Fact]
    public void BuildData_EmptyCollection()
    {
        CsvStudentReport.Instance.Export([]);
    }

}
