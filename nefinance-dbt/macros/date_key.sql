{% macro date_key(date_expression) -%}
    to_number(to_varchar({{ date_expression }}, 'YYYYMMDD'))
{%- endmacro %}
