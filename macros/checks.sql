{% macro check_timestamps(table_catalog, table_schema, table_name) %}
    {#{{log(table_catalog+"."+table_schema+"."+table_name,info = True)}}#}
    
    {%- set column_list_qry = run_query("SELECT COLUMN_NAME,DATA_TYPE FROM "+table_catalog+".INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG = '" + table_catalog + "' AND TABLE_SCHEMA = '" + table_schema + "' AND TABLE_NAME = '" + table_name + "'") -%}
    {%- if execute -%} 
        {%- set column_list = column_list_qry.columns[0].values()-%}
        {%- set column_types = column_list_qry.columns[1].values()-%}
           
    {%- endif -%}
    {%- set timestamp_columns = [] -%}
    {%- for n,t in zip(column_list,column_types) -%}
        {%- if t == 'TIMESTAMP' -%}
            {{ timestamp_columns.append(n)}}
            {{log(n+" : "+t)}}
        {%- endif -%}
    {%- endfor -%}
    
    {%- set timestamp_count = timestamp_list|length -%}
    {{log("  - There is " + timestamp_count|string + " TIMESTAMP Columns!", info = True)}}
    {{return(timestamp_list)}}
{%- endmacro -%}

{% macro columns_exist(table_catalog, table_schema, table_name, primary_key) %}
    {%- set column_list_qry = run_query("SELECT COLUMN_NAME FROM "+table_catalog+".INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG = '" + table_catalog + "' AND TABLE_SCHEMA = '" + table_schema + "' AND TABLE_NAME = '" + table_name + "'") -%}
    
    {%- if execute -%} 
        {%- set column_list = column_list_qry.columns[0].values()-%}           
    {%- endif -%}

    {%- set all_exist = [True] -%}
    
    {%- for k in primary_key -%}
        {%- if k not in column_list -%}
            {{log("  - Column " + k + " does not exist in table!", info = True)}}
            {{ return(False)}}
        {%- endif -%}
    {%- endfor -%}
    {{return(True)}}
{% endmacro %}

{% macro check_for_null(table_catalog, table_schema, table_name, column_name) %}
    {%- set qry_null_count = run_query("SELECT COUNT(*) FROM " + table_catalog + "." + table_schema + "." + table_name + " WHERE " + column_name + " IS NULL") -%}
    {%- if execute -%}
        {%- set null_count = qry_null_count.columns[0].values()[0] -%}
    {%- endif -%}
    {{return(null_count)}}
{% endmacro %}

{% macro check_key_unique(table_catalog, table_schema, table_name, primary_key) %}
    {%- set tbl = table_catalog + "." + table_schema + "." + table_name -%}}
    {%- set primary_keys = ",".join(primary_key) -%}

    {%- set qry_duplicity_count = run_query("SELECT COUNT(*) FROM (SELECT COUNT(*) FROM " + tbl+ " GROUP BY " + primary_keys + " HAVING COUNT(*) > 1)") -%}
    {%- if execute -%}
        {%- set duplicity_count = qry_duplicity_count.columns[0].values()[0] -%}
    {%- endif -%}
    
    {{return(duplicity_count == 0)}}
{% endmacro %}

{% macro check_primary_key(table_catalog, table_schema, table_name, primary_key) %}
    {#{{log(" EXIST CHECK", info = True)}}#}
    {%- set primary_key_exists = columns_exist(table_catalog,table_schema,table_name,primary_key) -%}
    {{log("  - Exist check ... " ~ primary_key_exists,info = True)}}

    {%- if primary_key_exists == True -%}
        {#{{log(" NULL CHECK", info = True)}}#}
        {%- set primary_key_is_not_null = True -%}
        {%- for k in primary_key -%}
            {%- if check_for_null(table_catalog,table_schema,table_name,k) > 0 -%}
                {%- set primary_key_is_not_null = False -%}
                {%- break -%}
            {%- endif -%}        
        {%- endfor -%}
        
        {{log("  - NULL check ... " ~ primary_key_is_not_null, info = True)}}

        
        {%- if primary_key_is_not_null == True -%}
            {#{{log(" DUPLICITY CHECK", info = True)}}#}
            {%- set primary_key_is_unique = check_key_unique(table_catalog, table_schema, table_name, primary_key) -%}
            {{log("  - Duplicity check ... " ~ primary_key_is_unique, info = True)}}
        {%- endif -%}
        

    

    {%- endif -%}
{% endmacro %}

 