namespace OpenClose;

public abstract class Employee
{
    internal protected static readonly decimal HourValue_FullTime = 30000M;
    internal protected static readonly decimal HourValue_PartTime = 20000M;

    public required string Fullname { get; set; }
    public required decimal HourValue { get; set; }
    public int HoursWorked { get; set; }

}