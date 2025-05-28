namespace SingleResponsability;

/// <summary>
/// Thread-safe, lazy initialized Singletone Student Repository.
/// </summary>
public sealed class StudentRepository : Repository<Student>
{
    private static readonly Lazy<StudentRepository> _instance =
        new(() => new StudentRepository());

    public static Repository<Student> Instance => _instance.Value;

    private StudentRepository() {}

    /// <summary>
    /// Idempotent method to initialize the internal storage with source data.
    /// </summary>
    /// <param name="source"></param>
    public override Repository<Student> InitData(IEnumerable<Student> source)
    {
        if (!_storage.Any())
        {
            AddAll(source);
        }
        return Instance;
    }

   }
