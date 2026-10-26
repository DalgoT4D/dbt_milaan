-- Find AWWs in aww table but not in aww_attendance_with_geo

SELECT
  w.aww_id,
  w.awc_id,
  w.aww_name,
  w.block_name,
  w.source_table,
  COUNT(a.session_id) AS attendance_count
FROM {{ ref('aww') }} w
LEFT JOIN {{ ref('aww_attendance') }} a ON w.awc_id = a.awc_id
GROUP BY w.aww_id, w.awc_id, w.aww_name, w.block_name, w.source_table
HAVING COUNT(a.session_id) = 0
ORDER BY w.block_name, w.source_table
