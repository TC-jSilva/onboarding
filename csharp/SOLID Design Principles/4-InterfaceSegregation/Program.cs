using InterfaceSegregation;

IDevActivities dev = new Developer();
IActivities sm =  new ScrumMaster();
IQActivities qa = new Tester();

Console.WriteLine("Activities in the dev process...");
sm.Plan();
dev.Develop();
qa.Test();

Console.WriteLine("Press any key to finish...");
Console.ReadKey();
