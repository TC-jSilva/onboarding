using System.Collections.ObjectModel;

namespace SingleResponsability;

public class FakeStorage<T>
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
        return new ObservableCollection<T>(_collection);
    }
}
