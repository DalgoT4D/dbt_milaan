{{ config(materialized='table', schema='production') }}

-- Production table: Attendance data enriched with geographic hierarchy
-- Starts with aww_attendance (all 16,521 records) and LEFT JOINs geo_master
-- Filtered to only the 15 blocks that have attendance data
-- Preserves all attendance records even if geographic data is missing

WITH blocks_with_attendance AS (
  SELECT DISTINCT g.block_id
  FROM {{ ref('geo_master') }} g
  WHERE g.awc_id IN (SELECT DISTINCT awc_id FROM {{ ref('aww_attendance') }})
)

SELECT
  a.awc_id,
  g.awc_name,
  g.sector_id,
  g.sector_name,
  g.block_id,
  g.block_name,
  g.district_id,
  g.district_name,
  g.state_id,
  g.state_name,
  a.session_id,
  a.session_date,
  a.status,
  a.created_at,
  a.updated_at,
  a.is_active
FROM {{ ref('aww_attendance') }} a
LEFT JOIN {{ ref('geo_master') }} g ON a.awc_id = g.awc_id
WHERE g.block_id IN (SELECT block_id FROM blocks_with_attendance)
   OR g.block_id IS NULL
