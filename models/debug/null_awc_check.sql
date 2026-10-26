-- Check for NULL awc_id values that might cause join issues

SELECT
  'aww' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN awc_id IS NULL THEN 1 END) AS null_awc_count,
  COUNT(DISTINCT awc_id) AS distinct_non_null_awc
FROM {{ ref('aww') }}

UNION ALL

SELECT
  'aww_attendance' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN awc_id IS NULL THEN 1 END) AS null_awc_count,
  COUNT(DISTINCT awc_id) AS distinct_non_null_awc
FROM {{ ref('aww_attendance') }}

UNION ALL

SELECT
  'aww_attendance_with_geo' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN awc_id IS NULL THEN 1 END) AS null_awc_count,
  COUNT(DISTINCT awc_id) AS distinct_non_null_awc
FROM {{ ref('aww_attendance_with_geo') }}
