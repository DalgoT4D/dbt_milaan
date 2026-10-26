-- Identify which blocks have attendance data

SELECT
  g.block_id,
  g.block_name,
  COUNT(DISTINCT g.awc_id) AS awc_count,
  COUNT(DISTINCT CASE WHEN a.session_id IS NOT NULL THEN a.session_id END) AS session_count,
  COUNT(DISTINCT a.session_date) AS unique_dates
FROM {{ ref('geo_master') }} g
LEFT JOIN {{ ref('aww_attendance') }} a ON g.awc_id = a.awc_id
GROUP BY g.block_id, g.block_name
HAVING COUNT(a.session_id) > 0
ORDER BY block_name
