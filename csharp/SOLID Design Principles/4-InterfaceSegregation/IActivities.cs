namespace InterfaceSegregation
{
    public interface IActivities
    {
        void Plan();
        void Comunicate();
    }

    public interface IDevActivities
    {
        void Design();
        void Develop();
    }

    public interface IQActivities
    {
        void Test();
    }
}