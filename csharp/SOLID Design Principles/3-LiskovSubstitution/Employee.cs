namespace LiskovSubstitution;

public abstract class Employee(string fullname, int hoursWorked)
{
    protected readonly decimal HourValue;

    public string Fullname { get; set; } = fullname;
    public int HoursWorked { get; set; } = hoursWorked;

    public abstract decimal CalculateSalary();
}
