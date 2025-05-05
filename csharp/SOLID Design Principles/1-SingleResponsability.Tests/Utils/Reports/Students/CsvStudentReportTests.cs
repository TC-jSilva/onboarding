using System.Collections.ObjectModel;

namespace SingleResponsability.Tests;

public class CsvStudentReportTests
{

    [Fact]
    public void BuildData_NotEmptyCollection()
    {
        CsvStudentReport.Instance.Export(StudentRepository.Instance.GetAll());
    }

    [Fact]
    public void BuildData_EmptyCollection()
    {
        ObservableCollection<Student> emptyCollection = [];
        CsvStudentReport.Instance.Export(emptyCollection);
    }

}
