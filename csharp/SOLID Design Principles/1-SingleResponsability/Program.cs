using SingleResponsability;

StudentRepository studentRepository = StudentRepository.Instance;
StudentReport.Export(studentRepository.GetAll());
Console.WriteLine("Process completed!");

Console.WriteLine("Press any key to finish...");
Console.ReadKey();
