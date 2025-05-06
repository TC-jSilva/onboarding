namespace LiskovSubstitution;

public class EmployeeContractor : Employee
{
    protected new readonly decimal HourValue = 40;

    public EmployeeContractor(string fullname, int hoursWorked) : base(fullname, hoursWorked)
    {
    }

    public override decimal CalculateSalary()
    {
        return HourValue * HoursWorked;
    }
}
