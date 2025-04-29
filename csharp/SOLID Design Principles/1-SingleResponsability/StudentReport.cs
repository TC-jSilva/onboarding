using System.Text;

namespace SingleResponsability;

/// <summary>
/// Utility to export student data to a CSV file.
/// </summary>
public static class StudentReport
{
    private static readonly string CsvColumnDelimiter = ",";
    private static readonly string CsvColumnNames = "Id;Fullname;Grades";
    private static readonly string CsvGradesDelimiter = "|";
    private static readonly string CsvFileName = "Students.csv";

    public static void Export(IEnumerable<Student> students)
    {
        string csv = String.Join(CsvColumnDelimiter, students.Select(x => x.ToString()).ToArray());
        StringBuilder sb = new();
        sb.AppendLine(CsvColumnNames);
        foreach (Student student in students)
        {
            sb.AppendLine($"{student.Id};{student.Fullname};{string.Join(CsvGradesDelimiter, student.Grades)}");
        }
        File.WriteAllText(System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, CsvFileName), sb.ToString(), Encoding.Unicode);
    }
}