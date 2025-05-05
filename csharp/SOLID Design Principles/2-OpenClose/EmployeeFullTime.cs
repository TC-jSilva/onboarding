using System.Diagnostics.CodeAnalysis;

namespace OpenClose
{
    public sealed class EmployeeFullTime : Employee, IAccountable
    {
        [SetsRequiredMembers]
        public EmployeeFullTime(string fullname, int hoursWorked)
        {
            Fullname = fullname;
            HourValue = Employee.HourValue_FullTime;
            HoursWorked = hoursWorked;
        }

        public decimal CalculateSalary()
        {
            return HourValue * HoursWorked;
        }
    }
}