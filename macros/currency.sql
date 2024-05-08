{% macro check_currency(table_catalog, table_schema, table_name) %}

    {{log("TABLE NAME:  " + table_name, info=true)}}

    {# Get the list of column names from the specified table #}
    {% set column_names = run_query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + table_name + "'") %}

    {%- if execute -%}

        {% for column in column_names %}
            {{log("---------------------------------------", info=true)}}
            {% set column2 = column.values()[0] %}
            {{log("COLUMN NAME: " + column2, info=true)}}
            {% set currency_query = run_query("SELECT currency FROM TABLES WHERE table_name = '" + table_name + "' AND COLUMN_NAME = '" + column2 + "'") %}
            {% set currency = currency_query[0].values()[0] %}
            {{log("IS_CURRENCY: " + currency|string, info=true)}}

            {% if currency %}
                {% set currency_list = run_query("SELECT DISTINCT ALPHABETICCODE FROM CURRENCY WHERE ALPHABETICCODE IS NOT NULL") %}
                {% for curr in currency_list %}
                    {% if "_" + curr.values()[0] + "_" in column2 or column2.endswith("_" + curr.values()[0]) %}
                        {{log("CURRENCY:    " + curr.values()[0],info=true)}}
                    {% endif %}
                {% endfor%}
            {% endif %}
        {% endfor %}
    {%- endif -%}
{% endmacro %}