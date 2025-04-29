using System.Text;

namespace SingleResponsability;

/// <summary>
/// Thread-safe, lazy initialized Singletone Student Repository.
/// </summary>
public sealed class StudentRepository
{
    private static readonly Lazy<StudentRepository> _instance =
        new(() => new StudentRepository());

    public static StudentRepository Instance => _instance.Value;
    private readonly FakeStorage<Student> _storage;

    private StudentRepository()
    {
        _storage = new();
        InitData();
    }

    private void InitData()
    {
        _storage.Add(new Student(1, "Pepito Pérez", [3, 4.5]));
        _storage.Add(new Student(2, "Mariana Lopera", [4, 5]));
        _storage.Add(new Student(3, "José Molina", [2, 3]));
    }

    /// <summary>
    /// Gets a thread-safe copy of internal repository data collection.
    /// </summary>
    /// <returns>Student data collection.</returns>
    public IEnumerable<Student> GetAll()
    {
        return _storage.GetAll();
    }

}
