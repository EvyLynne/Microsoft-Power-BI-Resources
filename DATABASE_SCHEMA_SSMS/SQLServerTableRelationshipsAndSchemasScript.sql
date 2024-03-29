-- PBI Report Query - adapted from https://dataedo.com/kb/query/sql-server/list-of-tables-in-schema
-- separated schema name from table name
-- added count for total dependent tables for each parent table

select schema_name(fk_tab.schema_id) foreign_schema,
	fk_tab.name as foreign_table,
    schema_name(pk_tab.schema_id) primary_schema,
	pk_tab.name as primary_table,
    fk_col.name as fk_column_name,
    pk_col.name as pk_column_name,
    fk.name as fk_constraint_name,
	fk_cols.constraint_column_id as [no of relationships],
	COUNT (pk_col.name) over (partition by pk_tab.name) as [Total Dependant Tables]
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
where pk_tab.name = 'Person'
order by schema_name(fk_tab.schema_id) + '.' + fk_tab.name,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name, 
    fk_cols.constraint_column_id
