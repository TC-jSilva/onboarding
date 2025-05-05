using SingleResponsability;

IList<Student> students = [
    new Student(1, "Pepito Pérez", [3, 4.5]),
    new Student(2, "Mariana Lopera", [4, 5]),
    new Student(3, "José Molina", [2, 3])];
Repository<Student> studentRepository = StudentRepository.Instance.InitData(students);

ReportExporter<Student, string, string> studentReport = CsvStudentReport.Instance;
studentReport.Export(studentRepository.GetAll());

Console.WriteLine("Process completed!");
Console.WriteLine("Press any key to finish...");
Console.ReadKey();
