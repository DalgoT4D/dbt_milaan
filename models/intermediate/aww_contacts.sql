{{ config(materialized='table', schema='intermediate') }}

-- Clean contacts data with standardized aww_center_code
-- Ensures aww_center_code is 10 digits with leading zeros to match awc_id format
-- For non-numeric codes, keep as-is for manual review

SELECT
  *,
  CASE
    WHEN aww_center_code ~ '^\d+$' THEN LPAD(aww_center_code, 10, '0')
    ELSE aww_center_code
  END AS awc_id
FROM {{ source('staging', 'contacts_flat') }}
