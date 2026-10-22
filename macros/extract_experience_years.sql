{#
  Extract and normalize experience values.
  Handles: pure numbers, "X years", "X months", "Xm", "Xy", etc.
  Converts months to years (divide by 12, round to 2 decimals).
  Returns NULL if empty or unparseable.
#}

{% macro extract_experience_years(col_name) %}
CASE
  WHEN {{ col_name }} IS NULL OR {{ col_name }} = '' THEN NULL
  WHEN {{ col_name }} ~ '^\d+$' THEN CAST({{ col_name }} AS NUMERIC)
  WHEN UPPER({{ col_name }}) LIKE '%MONTH%' OR UPPER({{ col_name }}) LIKE '%M'
    THEN ROUND(CAST(SUBSTRING({{ col_name }} FROM '^\d+') AS NUMERIC) / 12.0, 2)
  WHEN UPPER({{ col_name }}) LIKE '%YEAR%' OR UPPER({{ col_name }}) LIKE '%Y'
    THEN CAST(SUBSTRING({{ col_name }} FROM '^\d+') AS NUMERIC)
  ELSE NULL
END
{% endmacro %}
