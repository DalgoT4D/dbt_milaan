{{ config(materialized='table', schema='production') }}

-- AWW contacts registration status by block
-- Shows district/block coverage and registration gaps

SELECT
  w.district_name,
  w.block_name,
  w.district_id,
  w.block_id,
  COUNT(DISTINCT w.awc_id) AS total_awc,
  COUNT(DISTINCT CASE WHEN c.awc_id IS NULL THEN w.awc_id END) AS unregistered_awc,
  COUNT(DISTINCT CASE WHEN c.awc_id IS NOT NULL THEN w.awc_id END) AS registered_awc,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN c.awc_id IS NOT NULL THEN w.awc_id END) /
        COUNT(DISTINCT w.awc_id), 2) AS registration_percentage
FROM {{ ref('aww') }} w
LEFT JOIN {{ ref('aww_contacts') }} c ON w.awc_id = c.awc_id
WHERE w.district_name IS NOT NULL AND w.block_name IS NOT NULL
GROUP BY w.district_name, w.block_name, w.district_id, w.block_id
ORDER BY w.district_name, w.block_name
