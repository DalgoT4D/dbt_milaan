{{ config(materialized='table', schema='production') }}

-- Detailed list of unregistered AWCs (no contact information)
-- Grouped by district and block for easy identification

SELECT
  w.awc_id,
  w.aww_id,
  w.aww_name,
  w.district_id,
  w.district_name,
  w.block_id,
  w.block_name,
  w.sector_id,
  w.sector_name,
  w.age,
  w.religion,
  w.education,
  w.exp_years,
  w.mobile_no,
  w.email_id,
  w.source_table AS worker_source_table
FROM {{ ref('aww') }} w
LEFT JOIN {{ ref('aww_contacts') }} c ON w.awc_id = c.awc_id
WHERE c.awc_id IS NULL
  AND w.awc_id IS NOT NULL
  AND w.district_name IS NOT NULL
  AND w.block_name IS NOT NULL
ORDER BY w.district_name, w.block_name, w.aww_name
