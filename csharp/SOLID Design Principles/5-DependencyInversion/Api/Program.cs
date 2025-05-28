using System.Collections.ObjectModel;
using DependencyInversion;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
// Init Student Repository data
ObservableCollection<Student> initData = [];
initData.Add(new Student(1, "Pepito Pérez", [3, 4.5]));
initData.Add(new Student(2, "Mariana Lopera", [4, 5]));
initData.Add(new Student(3, "José Molina", [2, 3]));
builder.Services.AddSingleton<IRepository>(
    repo => new StudentRepository(initData));
builder.Services.AddSingleton<ILog, Logbook>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

