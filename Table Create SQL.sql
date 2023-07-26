-- set up schema for Power BI Reporting
IF NOT EXISTS (
SELECT  schema_name
FROM    information_schema.schemata
WHERE   schema_name = 'PowerBI' ) 
 
BEGIN
EXEC sp_executesql N'CREATE SCHEMA PowerBI'  
END
GO;

-- insert relationship information and create table
SELECT SCHEMA_NAME(pk_tab.schema_id) AS primary_schema,
	pk_tab.name AS primary_table,
	SCHEMA_NAME(fk_tab.schema_id) AS foreign_schema,
	fk_tab.name AS foreign_table,
    fk_col.name AS fk_column_name,
    pk_col.name AS pk_column_name,
    fk.name AS fk_constraint_name,
	fk_cols.constraint_column_id AS [no of relationships],
	COUNT (pk_col.name) OVER (PARTITION BY pk_tab.name) AS [Total Dependant Tables]
INTO PowerBI.ALL_RELATIONSHIPS -- I used all caps so it would stand out from the data
FROM sys.foreign_keys fk
    INNER JOIN sys.tables fk_tab
        ON fk_tab.object_id = fk.parent_object_id
    INNER JOIN sys.tables pk_tab
        ON pk_tab.object_id = fk.referenced_object_id
    INNER JOIN sys.foreign_key_columns fk_cols
        ON fk_cols.constraint_object_id = fk.object_id
    INNER JOIN sys.columns fk_col
        ON fk_col.column_id = fk_cols.parent_column_id
        AND fk_col.object_id = fk_tab.object_id
    INNER JOIN sys.columns pk_col
        ON pk_col.column_id = fk_cols.referenced_column_id
        AND pk_col.object_id = pk_tab.object_id
ORDER BY 2,4;

-- add identity column
ALTER TABLE PowerBI.ALL_RELATIONSHIPS   ADD ID INT IDENTITY(1,1) NOT NULL;
