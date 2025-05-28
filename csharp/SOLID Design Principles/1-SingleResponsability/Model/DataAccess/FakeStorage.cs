using System.Collections.ObjectModel;

namespace SingleResponsability;

public class FakeStorage<T> where T: IPersistable
{
    private readonly ObservableCollection<T> _collection;

    public FakeStorage()
    {
        _collection = [];
    }

    public T Add(T item)
    {
        _collection.Add(item);
        return item;
    }

    public T Remove(T item)
    {
        _collection.Remove(item);
        return item;
    }

    public IEnumerable<T> GetAll()
    {
        return _collection;
    }

    public bool Any()
    {
        return _collection.Any();
    }

}
