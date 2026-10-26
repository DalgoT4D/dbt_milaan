-- Check for workers with NULL awc_id in aww table

SELECT
  'With NULL awc_id' AS category,
  COUNT(*) AS worker_count,
  STRING_AGG(DISTINCT source_table, ', ' ORDER BY source_table) AS source_tables
FROM {{ ref('aww') }}
WHERE awc_id IS NULL

UNION ALL

SELECT
  'With non-NULL awc_id' AS category,
  COUNT(*) AS worker_count,
  STRING_AGG(DISTINCT source_table, ', ' ORDER BY source_table) AS source_tables
FROM {{ ref('aww') }}
WHERE awc_id IS NOT NULL
