-- Complete stored procedure information with parameters
SELECT 
    p.name AS ProcedureName,
    SCHEMA_NAME(p.schema_id) AS SchemaName,
    p.create_date AS CreatedDate,
    p.modify_date AS ModifiedDate,
    param.parameter_id,
    param.name AS ParameterName,
    TYPE_NAME(param.user_type_id) AS DataType,
    param.max_length,
    param.precision,
    param.scale,
    param.is_output,
    CASE 
        WHEN param.is_output = 1 THEN 'OUTPUT'
        WHEN param.parameter_id = 0 THEN 'RETURN VALUE'
        ELSE 'INPUT'
    END AS ParameterType,
    param.has_default_value,
    param.default_value
FROM sys.procedures p
LEFT JOIN sys.parameters param ON p.object_id = param.object_id
ORDER BY p.name, param.parameter_id;