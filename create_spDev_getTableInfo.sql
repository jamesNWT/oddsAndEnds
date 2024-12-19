
-- Create a stored procedure for SQL Server that can be used to easily
-- get the most important metadata from a given table.

CREATE PROCEDURE spDev_getTableInfo
    @tablename nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate if table exists
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tablename)
    BEGIN
        RAISERROR ('Table does not exist.', 16, 1);
        RETURN;
    END

    -- Get table metadata
    SELECT 
        c.column_name AS ColumnName, 
        c.data_type AS DataType, 
        c.character_maximum_length AS MaxLength,
        c.is_nullable AS IsNullable,
        c.column_default AS DefaultValue,
        kcu.constraint_name AS ForeignKeyName,
        CASE 
            WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'Yes'
            ELSE 'No'
        END AS IsPrimaryKey
    FROM 
        information_schema.columns c
    LEFT JOIN 
        information_schema.key_column_usage kcu 
        ON c.table_name = kcu.table_name 
        AND c.column_name = kcu.column_name
    LEFT JOIN 
        information_schema.table_constraints tc 
        ON c.table_name = tc.table_name 
        AND kcu.constraint_name = tc.constraint_name
    WHERE 
        c.table_name = @tablename
    ORDER BY 
        CASE 
            WHEN tc.constraint_type = 'PRIMARY KEY' THEN 0
            ELSE 1
        END,
        c.column_name;
END