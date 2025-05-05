using LiskovSubstitution;

CalculateSalaryMonthly([
    new EmployeeFullTime("Pepito Pérez", 160, 10),
    new EmployeeContractor("Manuel Lopera", 180)
]);

void CalculateSalaryMonthly(List<Employee> employees)
{
    foreach (var item in employees)
    {
        decimal salary = item.CalculateSalary();
        Console.WriteLine($"The {item.Fullname}'s salary is {salary}");
    }

    Console.WriteLine("Press any key to finish...");
    Console.ReadKey();
}
