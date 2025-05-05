using System.Diagnostics.CodeAnalysis;

namespace OpenClose
{
    public sealed class EmployeePartTime : Employee
    {
        private static readonly int _HoursWorkedLimit = 160;
        private static readonly decimal _EffortCompensation = 5000M;

        [SetsRequiredMembers]
        public EmployeePartTime(string fullname, int hoursWorked)
        {
            Fullname = fullname;
            HoursWorked = hoursWorked;
            HourValue = Employee.HourValue_PartTime;
        }

        public override decimal CalculateSalary()
        {
            decimal salary = HourValue * HoursWorked;
            if (HoursWorked > _HoursWorkedLimit) {
                int extraDays = HoursWorked - _HoursWorkedLimit;
                salary += _EffortCompensation * extraDays;
            }
            return salary;
        }
    }
}