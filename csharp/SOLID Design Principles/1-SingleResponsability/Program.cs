using SingleResponsability;

IExportable<Student> studentReport = CsvStudentReport.Instance;
studentReport.Export(StudentRepository.Instance.GetAll());
Console.WriteLine("Process completed!");

Console.WriteLine("Press any key to finish...");
Console.ReadKey();
