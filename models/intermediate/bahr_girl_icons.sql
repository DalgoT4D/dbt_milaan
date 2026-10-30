{{ config(materialized='table', schema='intermediate') }}

-- Merge all bahr_gi_* tables with dynamic schema handling
-- Add girl_icon_id by matching center_code + first name from attendance table

{% if execute %}
  -- Get all table names (only bahr_gi_* tables, exclude bahr_gi_att_*)
  {% set tables_query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'staging' AND table_name LIKE 'bahr_gi_%' AND table_name NOT LIKE 'bahr_gi_att_%' ORDER BY table_name" %}
  {% set table_results = run_query(tables_query) %}
  {% set sources = table_results.columns[0].values() %}

  -- Get all unique columns across all tables (only bahr_gi_* tables, exclude bahr_gi_att_*)
  {% set columns_query = "SELECT DISTINCT column_name FROM information_schema.columns WHERE table_schema = 'staging' AND table_name LIKE 'bahr_gi_%' AND table_name NOT LIKE 'bahr_gi_att_%' ORDER BY column_name" %}
  {% set column_results = run_query(columns_query) %}
  {% set all_columns = column_results.columns[0].values() %}

  -- Get columns for each table (to check which are missing)
  {% set table_columns = {} %}
  {% for src_name in sources %}
    {% set col_query = "SELECT column_name FROM information_schema.columns WHERE table_schema = 'staging' AND table_name = '" ~ src_name ~ "' ORDER BY column_name" %}
    {% set col_result = run_query(col_query) %}
    {% set table_columns = table_columns.update({src_name: col_result.columns[0].values()}) %}
  {% endfor %}

  -- Build list of columns to output (exclude: Center_Name_, S_N, S_No, S_NO, Mobile_, Mobile_No_)
  {% set output_cols = [] %}
  {% for col in all_columns %}
    {% if col not in ['Center_Name_', 'S_N', 'S_No', 'S_NO', 'Mobile_', 'Mobile_No_'] %}
      {% do output_cols.append(col) %}
    {% endif %}
  {% endfor %}

{% else %}
  {% set sources = [] %}
  {% set all_columns = [] %}
  {% set table_columns = {} %}
  {% set output_cols = [] %}
{% endif %}

SELECT
  base.*
FROM (
  {% for src_name in sources %}
  (
  SELECT
    {% for col in output_cols %}
      {% if col == 'Center_Name' %}
        {% if 'Center_Name' in table_columns[src_name] %}"Center_Name"{% elif 'Center_Name_' in table_columns[src_name] %}"Center_Name_"{% else %}NULL{% endif %} AS "center_name",
      {% elif col == 'Girl_Leader__Saathi_Leaders' %}
        CASE
          WHEN LOWER(TRIM({% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %})) LIKE '%girl%' OR
               LOWER(TRIM({% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %})) LIKE '%group%' THEN 'Girl Leader'
          WHEN LOWER(TRIM({% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %})) LIKE '%saathi%' OR
               LOWER(TRIM({% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %})) LIKE '%sathi%' OR
               LOWER(TRIM({% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %})) LIKE '%sarhi%' THEN 'Saathi Leader'
          ELSE {% if 'Girl_Leader__Saathi_Leaders' in table_columns[src_name] %}"Girl_Leader__Saathi_Leaders"{% else %}NULL{% endif %}
        END AS "girl_leader__saathi_leaders",
      {% elif col == 'mobile' %}
        COALESCE({% if 'mobile' in table_columns[src_name] %}"mobile"{% else %}NULL{% endif %}, {% if 'mobile_' in table_columns[src_name] %}"mobile_"{% else %}NULL{% endif %}, {% if 'mobile_no_' in table_columns[src_name] %}"mobile_no_"{% else %}NULL{% endif %}) AS "mobile",
      {% else %}
        {% if col in table_columns[src_name] %}"{{ col }}"{% else %}NULL{% endif %} AS "{{ col | lower }}",
      {% endif %}
    {% endfor %}
    '{{ src_name }}' AS source_table,
    current_timestamp AS created_at,
    current_timestamp AS updated_at
  FROM staging."{{ src_name }}"
  )
  {% if not loop.last %}UNION ALL{% endif %}
  {% endfor %}
) base
