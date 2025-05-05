namespace SingleResponsability;

/// <summary>
/// Abstract class for writing data to a target in a particular encoding.
/// </summary>
public abstract class OutputWriter<DataType, TargetType>
{

    /// <summary>
    /// Writes the data source to a given target.
    /// </summary>
    /// <param name="data">Data Type</param>
    /// <param name="target">Target Type</param>
    public abstract void Write(DataType data, TargetType target);
}