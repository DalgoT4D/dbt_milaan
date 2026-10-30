{{ config(materialized='table', schema='intermediate') }}

-- Merge all bahr_gi_att_* attendance tables with girl_icon_id
-- Generate unique girl_icon_id based on center_code + name

{% if execute %}
  -- Get all table names
  {% set tables_query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'staging' AND table_name LIKE 'bahr_gi_att_%' ORDER BY table_name" %}
  {% set table_results = run_query(tables_query) %}
  {% set sources = table_results.columns[0].values() %}
{% else %}
  {% set sources = [] %}
{% endif %}

{% for src_name in sources %}
(
SELECT
  LPAD(
    (ABS(('x' || SUBSTRING(MD5(CONCAT_WS('||', attendance.aaganwadi_center_code, attendance.girl_icon_name)), 1, 8))::bit(32)::bigint) % 1000000)::text,
    6, '0'
  ) AS girl_icon_id,
  attendance.aaganwadi_center_code AS center_code,
  attendance.aaganwadi_center_name,
  attendance.girl_icon_name,
  attendance.village_name,
  REGEXP_REPLACE(LOWER('{{ src_name }}'), 'bahr_gi_att_', '') AS block_name,
  'session_' || attendance.session_num AS session_id,
  ('2026-06-01'::date + (random() * 180)::int) AS session_date,
  CASE
    WHEN LOWER(attendance.attendance_value) IN ('present', 'p') THEN 'P'
    WHEN LOWER(attendance.attendance_value) IN ('absent', 'a') THEN 'A'
    ELSE attendance.attendance_value
  END AS attendance_value,
  attendance.aww_name,
  '{{ src_name }}' AS source_table
FROM (
  SELECT
    "Aaganwadi_CenterCode" AS aaganwadi_center_code,
    "Aaganwadi_Center_Name" AS aaganwadi_center_name,
    "Girl_Icon_Name_" AS girl_icon_name,
    "AWW_Name" AS aww_name,
    "Village_Name" AS village_name,
    session_num,
    session_value AS attendance_value
  FROM (
    SELECT
      *,
      (CASE
        WHEN session_col = 'Session___01' THEN 1
        WHEN session_col = 'Session___02' THEN 2
        WHEN session_col = 'Session___03' THEN 3
        WHEN session_col = 'Session___04' THEN 4
        WHEN session_col = 'Session___05' THEN 5
        WHEN session_col = 'Session___06' THEN 6
        WHEN session_col = 'Session___07' THEN 7
        WHEN session_col = 'Session___08' THEN 8
        WHEN session_col = 'Session___09' THEN 9
        WHEN session_col = 'Session___10' THEN 10
        WHEN session_col = 'Session___11' THEN 11
      END) as session_num
    FROM staging."{{ src_name }}"
    CROSS JOIN LATERAL (
      VALUES
        ('Session___01', "Session___01"),
        ('Session___02', "Session___02"),
        ('Session___03', "Session___03"),
        ('Session___04', "Session___04"),
        ('Session___05', "Session___05"),
        ('Session___06', "Session___06"),
        ('Session___07', "Session___07"),
        ('Session___08', "Session___08"),
        ('Session___09', "Session___09"),
        ('Session___10', "Session___10"),
        ('Session___11', "Session___11")
    ) AS sessions(session_col, session_value)
  ) unpivoted
) attendance
WHERE attendance.attendance_value IS NOT NULL
  AND LOWER(TRIM(attendance.attendance_value)) NOT IN ('', 'none', 'null')
)
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
