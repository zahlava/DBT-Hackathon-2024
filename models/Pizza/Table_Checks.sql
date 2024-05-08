{%- set table_catalog = "HACKATHON"%}

{%- set qry_table_list = run_query("SELECT TABLE_NAME FROM " + table_catalog + ".INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'") -%}
{%- if execute -%}
    {%- set table_list = qry_table_list.columns[0].values() -%}
    {{log("Table list:",info = True)}}
    {{log(table_list,info = True)}}
{%- endif%}

{%- for t in table_list -%}
    {{log("Checking table: "+t, info = True)}}
    {{ check_timestamps(table_catalog=table_catalog, table_schema ="DATA_SAMPLE", table_name=t) }}
    {{ check_primary_key(table_catalog = table_catalog,table_schema = "DATA_SAMPLE", table_name = t, primary_key = ["ID"])}}
    
    {{ check_currency(table_catalog = table_catalog,table_schema = "DATA_SAMPLE", table_name = t)}}

{%- endfor -%}

SELECT *
FROM HACKATHON.DATA_SAMPLE.PIZZA_CUSTOMERS

