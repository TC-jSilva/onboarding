using OpenClose;

CalculateSalaryMonthly([
    new EmployeeFullTime(fullname:"Pepito Pérez", hoursWorked: 160),
    new EmployeePartTime(fullname: "Manuel Lopera", hoursWorked: 180)
]);


void CalculateSalaryMonthly(List<Employee> employees)
{
    foreach (var employee in employees)
    {
        Console.Write($"Empleado: {employee.Fullname}");
        if(employee is IAccountable accountable)
        {
            Console.Write($", Pago: {accountable.CalculateSalary():C1} ");
        }
        Console.WriteLine();
    }

    Console.WriteLine("Press any key to finish...");
    Console.ReadKey();
}