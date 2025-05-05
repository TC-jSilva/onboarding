namespace SingleResponsability;

/// <summary>
/// Generic Report Utility.
/// </summary>
/// <typeparam name="EntityType">Persistable Entity Type</typeparam>
public abstract class ReportExporter<EntityType, DataType, TargetType> where EntityType : IPersistable
{
    protected OutputWriter<DataType, TargetType>? _writer;

    /// <summary>
    /// Writes the data source to a report.
    /// </summary>
    /// <param name="src">Data Source</param>
    public void Export(IEnumerable<EntityType> src)
    {
        BuildData(src, out DataType data, out TargetType target);
        _writer?.Write(data, target);
    }

    /// <summary>
    /// Converts the data from src to a string with a specific format, to be written to a destined file.
    /// </summary>
    /// <param name="src">Data Source</param>
    /// <param name="out data">Content Type</param>
    /// <param name="out file">Target Type</param>
    protected abstract void BuildData(IEnumerable<EntityType> src, out DataType data, out TargetType target);
}