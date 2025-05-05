namespace LiskovSubstitution;

public class EmployeeFullTime : Employee
{
    protected new readonly decimal HourValue = 60;

    public int ExtraHours { get; set; }
    public EmployeeFullTime(string fullname, int hoursWorked, int extraHours) : base(fullname, hoursWorked)
    {
        ExtraHours = extraHours;
    }

    public override decimal CalculateSalary()
    {
        return HourValue * (HoursWorked + ExtraHours);
    }
}
