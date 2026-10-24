{% macro inspect_table(schema_name, table_name) %}
  {% if execute %}
    {% set query %}
      SELECT column_name, ordinal_position
      FROM information_schema.columns
      WHERE table_schema = '{{ schema_name }}'
        AND table_name = '{{ table_name }}'
      ORDER BY ordinal_position
    {% endset %}
    {% set results = run_query(query) %}
    {% if results %}
      {% do log("Columns in " ~ schema_name ~ "." ~ table_name ~ ":", info=true) %}
      {% for row in results.rows %}
        {% do log("  " ~ row.ordinal_position ~ ". " ~ row.column_name, info=true) %}
      {% endfor %}
    {% endif %}
  {% endif %}
{% endmacro %}
