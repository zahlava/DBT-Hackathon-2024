{% macro delete_empty_columns(TAB_var="HACKATHON.DATA_SAMPLE.PIZZA_ORDERS",COL_var="SELECT * FROM HACKATHON.DATA_SAMPLE.PIZZA_ORDERS") %}

{%- call statement('null_count_test', fetch_result=true) %}  

WITH T1 AS ( SELECT COUNT(*) AS "a" FROM TAB_var),
     T2 AS ( SELECT COUNT(*) AS "b" FROM TAB_var WHERE COL_var IS NULL)    
SELECT "b" / "a" FROM T1,T2
                                             
{%- endcall -%}
{%- set variable_prep = load_result('null_count_test') -%}
{% if execute %}    
    {% set variable = variable_prep['data'] %}
{% endif %}

{%- if variable < 0.3 -%}

{% set columns_to_delete = [] %}
        {%- set column_list_sql = ref(TAB_var).columns -%}
        
        {%- for column in column_list_sql -%}
            {%- set col_null_ratio = run_query("SELECT COUNT(*) AS total_rows, COUNT({{ COL_var }}) AS non_null_rows FROM {{ TAB_var }}") -%}
            {%- set ratio = col_null_ratio[0]['non_null_rows'] / col_null_ratio[0]['total_rows'] -%}
            
            {%- if ratio < 0.3 -%}
                {% set columns_to_delete = columns_to_delete + [column.name] %}
            {%- endif -%}
        {%- endfor -%}
        
        {% if columns_to_delete %}
            {%- set drop_columns_sql = "ALTER TABLE " ~ TAB_var ~ " DROP COLUMN " ~ columns_to_delete|join(', ') -%}
            {{ drop_columns_sql }}
        {% endif %}

{%- endif -%}

{% endmacro %}