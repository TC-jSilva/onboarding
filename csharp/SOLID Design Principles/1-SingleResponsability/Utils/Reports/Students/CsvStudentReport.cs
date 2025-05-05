using System.Text;

namespace SingleResponsability;

/// <summary>
/// Thread-safe, lazy initialized Singletone utility to export student data to a CSV file.
/// </summary>
public sealed class CsvStudentReport : ReportExporter<Student, string, string>
{
    private static readonly string CsvColumnNames = "Id;Fullname;Grades";
    private static readonly string CsvColumnDelimiter = ";";
    private static readonly string CsvGradesDelimiter = "|";
    private static readonly string CsvFileName = "Students.csv";

    private static readonly Lazy<CsvStudentReport> _instance =
        new(() => new CsvStudentReport());

    private CsvStudentReport()
    {
        _writer = new FileWriter();
    }

    public static CsvStudentReport Instance => _instance.Value;

    /// <summary>
    /// Builds the data from src to a string with a specific format, to be written to a destined file.
    /// </summary>
    /// <param name="src"></param>
    /// <param name="out data"></param>
    /// <param name="out file"></param>
    protected override void BuildData(IEnumerable<Student> src, out string data, out string file)
    {
        StringBuilder sb = new();
        sb.AppendLine(CsvColumnNames);
        foreach (Student student in src)
        {
            sb.AppendLine($"{student.Id}{CsvColumnDelimiter}{student.Fullname}{CsvColumnDelimiter}{string.Join(CsvGradesDelimiter, student.Grades)}");
        }
        file = CsvFileName;
        data = sb.ToString();
    }

}
