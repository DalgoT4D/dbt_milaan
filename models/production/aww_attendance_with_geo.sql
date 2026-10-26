{{ config(materialized='table', schema='production') }}

-- Production table: All AWWs with their attendance records and geographic hierarchy
-- Base table: aww (all 3,059 workers)
-- LEFT JOIN attendance (only those with records) and geo_master (geographic enrichment)

SELECT
  w.aww_id,
  w.awc_id,
  w.aww_name,
  w.sector_id,
  w.sector_name,
  w.block_id,
  w.block_name,
  w.district_id,
  w.district_name,
  a.session_id,
  a.session_date,
  a.status,
  a.source_table AS attendance_source_table,
  w.source_table AS worker_source_table,
  w.age,
  w.religion,
  w.education,
  w.exp_years,
  w.mobile_no,
  w.email_id,
  w.created_at,
  w.updated_at,
  w.is_active
FROM {{ ref('aww') }} w
LEFT JOIN {{ ref('aww_attendance') }} a ON w.awc_id = a.awc_id
