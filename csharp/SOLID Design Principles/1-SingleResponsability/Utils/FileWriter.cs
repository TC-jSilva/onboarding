using System.Text;

namespace SingleResponsability;

/// <summary>
/// Implements a OutputWriter for writing characters to a file in Unicode.
/// </summary>
public class FileWriter : OutputWriter<string, string>
{
    /// <summary>
    /// Writes the text data to a given file in Unicode.
    /// </summary>
    /// <param name="data">Data Source</param>
    /// <param name="file">File Name</param>
    public override void Write(string data, string file)
    {
        File.WriteAllText(
            Path.Combine(AppDomain.CurrentDomain.BaseDirectory, file),
                data,
                    Encoding.Unicode);
    }
}