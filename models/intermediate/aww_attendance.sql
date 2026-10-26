{{ config(materialized='table', schema='intermediate') }}

-- Final attendance table with status mapping and audit columns.

SELECT
  awc_id,
  session_id,
  session_date,
  CASE WHEN session_value = 'Present' THEN 'P' WHEN session_value = 'Absent' THEN 'A' ELSE NULL END AS status,
  source_table,
  current_timestamp AS created_at,
  current_timestamp AS updated_at,
  TRUE AS is_active
FROM {{ ref('aww_attendance_raw') }}
