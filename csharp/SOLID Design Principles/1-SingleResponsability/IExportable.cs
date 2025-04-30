using System.Text;

namespace SingleResponsability;

/// <summary>
/// Exportable behavior for reporting.
/// </summary>
/// <typeparam name="T"></typeparam>
public interface IExportable<T> where T : IStorable
{

    /// <summary>
    /// Writes the data from src to a Unicode encoded file in the system.
    /// </summary>
    /// <param name="src"></param>
    void Export(IEnumerable<T> src)
    {
        BuildData(src, out string data, out string file);
        File.WriteAllText(
            Path.Combine(AppDomain.CurrentDomain.BaseDirectory, file),
                data,
                    Encoding.Unicode);
    }

    /// <summary>
    /// Builds the data from src to a string with a specific format, to be written to a destined file.
    /// </summary>
    /// <param name="src"></param>
    /// <param name="out data"></param>
    /// <param name="out file"></param>
    internal void BuildData(IEnumerable<T> src, out string data, out string file);
}