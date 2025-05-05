using OpenClose;

CalculateSalaryMonthly([
    new EmployeeFullTime(fullname:"Pepito Pérez", hoursWorked: 160),
    new EmployeePartTime(fullname: "Manuel Lopera", hoursWorked: 180)
]);


void CalculateSalaryMonthly(List<Employee> employees)
{
    foreach (var employee in employees)
    {
        Console.WriteLine($"Empleado: {employee.Fullname}, Pago: {employee.CalculateSalary():C1} ");
    }

    Console.WriteLine("Press any key to finish...");
    Console.ReadKey();
}