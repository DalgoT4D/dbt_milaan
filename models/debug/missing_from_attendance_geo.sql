-- Find the 19 workers in aww but not in aww_attendance_with_geo

SELECT
  w.aww_id,
  w.awc_id,
  w.aww_name,
  w.block_name,
  w.district_name,
  w.source_table
FROM {{ ref('aww') }} w
WHERE w.awc_id NOT IN (SELECT DISTINCT awc_id FROM {{ ref('aww_attendance_with_geo') }} WHERE awc_id IS NOT NULL)
ORDER BY w.block_name, w.source_table, w.aww_name
