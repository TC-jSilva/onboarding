using System.Collections.ObjectModel;

namespace DependencyInversion
{
    public class StudentRepository(ObservableCollection<Student>? initData = null) : IRepository
    {
        private readonly ObservableCollection<Student> storage = initData ?? [];

        public IEnumerable<Student> GetAll()
        {
            return storage;
        }

        public void Add(Student student)
        {
            storage.Add(student);
        }
    }

    public interface IRepository
    {
        public IEnumerable<Student> GetAll();
        public void Add(Student student);
    }
}