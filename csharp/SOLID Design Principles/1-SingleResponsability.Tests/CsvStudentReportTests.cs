using System.Collections.ObjectModel;

namespace SingleResponsability.Tests;

public class CsvStudentReportTests
{

    [Fact]
    public void BuildData_NotEmptyCollection()
    {
        BuildData(StudentRepository.Instance.GetAll());
    }

    [Fact]
    public void BuildData_EmptyCollection()
    {
        ObservableCollection<Student> emptyCollection = [];
        BuildData(emptyCollection);
    }

    private void BuildData(IEnumerable<Student> src) {
        CsvStudentReport.Instance.BuildData(
            src,
                out string data,
                    out string file);
        Assert.NotNull(data);
        Assert.NotEmpty(data);
        Assert.NotNull(file);
        Assert.NotEmpty(file);
    }
}
