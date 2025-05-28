namespace InterfaceSegregation
{
    public class Developer : IDevActivities
    {
        public Developer()
        {
        }

        public void Design()
        {
            Console.WriteLine("I'm designing the functionalities required");
        }

        public void Develop()
        {
            Console.WriteLine("I'm developing the functionalities required");
        }
    }
}