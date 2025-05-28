using System.Collections.ObjectModel;

namespace SingleResponsability;

/// <summary>
/// Represents a Single Point of Access and Storage for a specific Persistable Entity.
/// </summary>
/// <typeparam name="T">Persistable Data Type</typeparam>
public abstract class Repository<T> where T: IPersistable
{
    protected readonly FakeStorage<T> _storage = new();

    /// <summary>
    /// Idempotent method to initialize the internal storage with source data.
    /// </summary>
    /// <param name="source"></param>
    /// <returns></returns>
    public abstract Repository<T> InitData(IEnumerable<T> source);

    /// <summary>
    /// Adds the source data to the internal storage.
    /// </summary>
    /// <param name="source"></param>
    public void AddAll(IEnumerable<T> source)
    {
        foreach(T record in source)
        {
            _storage.Add(record);
        }
    }

    /// <summary>
    /// Gets a read-only copy of the internal repository data.
    /// </summary>
    /// <returns>Student data collection.</returns>
    public ReadOnlyCollection<T> GetAll()
    {
        return new ReadOnlyCollection<T>([.. _storage.GetAll()]);
    }
}