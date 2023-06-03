--  Check DB actual totals
 
SELECT count(*) [Total Tables],
'Total Tables' [Type]
FROM INFORMATION_SCHEMA.TABLES
WHERE table_type = 'BASE TABLE'
 
SELECT COUNT(*) [Total Relationships],
'Total Relationships' [Relationships]
FROM information_schema.referential_constraints 

-- all columns in the entire database that can be joined 
-- I did this in two steps for simplicity 

SELECT 
cols.TABLE_NAME,
cols.COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS cols
INNER JOIN 
	(SELECT
		COLUMN_NAME
		FROM INFORMATION_SCHEMA.COLUMNS
		GROUP BY COLUMN_NAME
		HAVING COUNT (*) > 1

	) dupes
ON dupes.COLUMN_NAME = cols.COLUMN_NAME

 update [AdventureWorks2022].[dbo].[ALL_POSSIBLE_RELATIONSHIPS]
 set TableSchemaName = INFORMATION_SCHEMA.TABLES.TABLE_SCHEMA
 FROM [AdventureWorks2022].[dbo].[ALL_POSSIBLE_RELATIONSHIPS]
 INNER JOIN  INFORMATION_SCHEMA.TABLES 
 ON [AdventureWorks2022].[dbo].[ALL_POSSIBLE_RELATIONSHIPS].tbl_name = INFORMATION_SCHEMA.TABLES.TABLE_NAME

-- all relationships in database

select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
    '>--' as rel,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table,
    fk_cols.constraint_column_id as no, 
    fk_col.name as fk_column_name,
    ' = ' as [join],
    pk_col.name as pk_column_name,
    fk.name as fk_constraint_name
from sys.foreign_keys fk
    inner join sys.tables fk_tab
        on fk_tab.object_id = fk.parent_object_id
    inner join sys.tables pk_tab
        on pk_tab.object_id = fk.referenced_object_id
    inner join sys.foreign_key_columns fk_cols
        on fk_cols.constraint_object_id = fk.object_id
    inner join sys.columns fk_col
        on fk_col.column_id = fk_cols.parent_column_id
        and fk_col.object_id = fk_tab.object_id
    inner join sys.columns pk_col
        on pk_col.column_id = fk_cols.referenced_column_id
        and pk_col.object_id = pk_tab.object_id
order by schema_name(fk_tab.schema_id) + '.' + fk_tab.name,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name, 
    fk_cols.constraint_column_id


-- Removes duplicate joins after CTE query executes

;With CTE_FK AS (
	SELECT Schema_Name(Schema_id) as TableSchemaName,
	  object_name(FK.parent_object_id) ParentTableName,
	  object_name(FK.referenced_object_id) ReferenceTableName,
	  FK.name AS ForeignKeyConstraintName,
	  c.name as ReferencedColumn,
	  cf.name as ParentColumnName 
	FROM sys.foreign_keys AS FK
		INNER JOIN sys.foreign_key_columns AS FKC
			ON FK.OBJECT_ID = FKC.constraint_object_id
		INNER JOIN sys.columns c
			ON  c.OBJECT_ID = FKC.referenced_object_id
			AND c.column_id = FKC.referenced_column_id
		INNER JOIN sys.columns cf
			ON  cf.OBJECT_ID = FKC.parent_object_id
			AND cf.column_id = FKC.parent_column_id
)
Select 
       ParentTableName,
       ReferenceTableName,
       ForeignKeyConstraintName,
	   
	   stuff(
				(
					Select ','+ParentColumnName
					from CTE_FK i
					where i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
						and i.TableSchemaName=o.TableSchemaName
						and i.ParentTableName=o.ParentTableName
						and i.ReferenceTableName=o.ReferenceTableName
					for xml path('')), 1, 1, '') ParentColumnList
					,
		stuff(
						(
							Select ','+ ReferencedColumn
							from CTE_FK i
							where i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
								and i.TableSchemaName=o.TableSchemaName
								and i.ParentTableName=o.ParentTableName
								and i.ReferenceTableName=o.ReferenceTableName
							for xml path('')), 1, 1, '') RefColumnList,
							COUNT (ReferencedColumn) over (partition by ParentTableName) as [Total Fks],
							TableSchemaName
							from CTE_FK o


-- select tables with multiple columns in relationship

;With CTE_FK AS (
SELECT 
	OBJECT_NAME(FK.parent_object_id) ParentTableName,
	OBJECT_NAME(FK.referenced_object_id) ReferenceTableName,
	FK.name AS ForeignKeyConstraintName,
	c.name as ReferencedColumnList,
	cf.name as ParentColumnName 
FROM sys.foreign_keys AS FK
INNER JOIN sys.foreign_key_columns AS FKC
	ON FK.OBJECT_ID = FKC.constraint_object_id
INNER JOIN sys.columns c
	ON  c.OBJECT_ID = FKC.referenced_object_id
	AND c.column_id = FKC.referenced_column_id
INNER JOIN sys.columns cf
	ON  cf.OBJECT_ID = FKC.parent_object_id
	AND cf.column_id = FKC.parent_column_id
)
SELECT  
      UPPER( ParentTableName ) ParentTableName,
      UPPER( ReferenceTableName ) ReferenceTableName,
       ForeignKeyConstraintName,
	  UPPER( STUFF((
		   SELECT ', '+ ParentColumnName
		   FROM CTE_FK i
		   WHERE i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
			AND i.ParentTableName=o.ParentTableName
			AND i.ReferenceTableName=o.ReferenceTableName
			FOR xml path('')), 1, 1, '') ) ParentColumnList,
       UPPER( STUFF((
             SELECT ', '+ReferencedColumnList
             FROM CTE_FK i
             WHERE i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
			  AND i.ParentTableName=o.ParentTableName
			  AND i.ReferenceTableName=o.ReferenceTableName
			  FOR xml path('')), 1, 1, '') ) RefColumnList
FROM CTE_FK o
where STUFF((
		   SELECT ', '+ ParentColumnName
		   FROM CTE_FK i
		   WHERE i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
			AND i.ParentTableName=o.ParentTableName
			AND i.ReferenceTableName=o.ReferenceTableName
			FOR xml path('')), 1, 1, '') like '%,%'
GROUP BY 
ParentTableName,
ReferenceTableName,
ForeignKeyConstraintName

-- Verbose mode adding count
select  UPPER( fk_tab.name ) as foreign_table,
    '>--' as rel,
     UPPER (pk_tab.name ) as primary_table,
     UPPER (fk_col.name) as fk_column_name,
     ' = ' as [join],
     UPPER (pk_col.name) as pk_column_name,
     fk.name as fk_constraint_name,
	 Count(fk.name) OVER(partition by pk_tab.name) as [total fks used]
from sys.foreign_keys fk
    inner join sys.tables fk_tab
        on fk_tab.object_id = fk.parent_object_id
    inner join sys.tables pk_tab
        on pk_tab.object_id = fk.referenced_object_id
    inner join sys.foreign_key_columns fk_cols
        on fk_cols.constraint_object_id = fk.object_id
    inner join sys.columns fk_col
        on fk_col.column_id = fk_cols.parent_column_id
        and fk_col.object_id = fk_tab.object_id
    inner join sys.columns pk_col
        on pk_col.column_id = fk_cols.referenced_column_id
        and pk_col.object_id = pk_tab.object_id


--  https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-foreign-key-columns-transact-sql?view=sql-server-ver16

SELECT fk.name AS ForeignKeyName
    , t_parent.name AS ParentTableName
    , c_parent.name AS ParentColumnName
    , t_child.name AS ReferencedTableName
    , c_child.name AS ReferencedColumnName
FROM sys.foreign_keys fk 
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t_parent
    ON t_parent.object_id = fk.parent_object_id
INNER JOIN sys.columns c_parent
    ON fkc.parent_column_id = c_parent.column_id  
    AND c_parent.object_id = t_parent.object_id 
INNER JOIN sys.tables t_child
    ON t_child.object_id = fk.referenced_object_id
INNER JOIN sys.columns c_child
    ON c_child.object_id = t_child.object_id
    AND fkc.referenced_column_id = c_child.column_id
ORDER BY t_parent.name, c_parent.name;

-- time queries
SET STATISTICS TIME ON;


-- schemas being used 
select distinct (schema_name(fk_tab.schema_id) ) [Active Schemas]
 
from sys.foreign_keys fk
    inner join sys.tables fk_tab
        on fk_tab.object_id = fk.parent_object_id
    inner join sys.tables pk_tab
        on pk_tab.object_id = fk.referenced_object_id
    inner join sys.foreign_key_columns fk_cols
        on fk_cols.constraint_object_id = fk.object_id
    inner join sys.columns fk_col
        on fk_col.column_id = fk_cols.parent_column_id
        and fk_col.object_id = fk_tab.object_id
    inner join sys.columns pk_col
        on pk_col.column_id = fk_cols.referenced_column_id
        and pk_col.object_id = pk_tab.object_id

