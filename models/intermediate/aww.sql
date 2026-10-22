{{ config(materialized='table', schema='intermediate') }}

-- Unified AWW table from 15 Postgres sources (staging schema).
-- Only valid rows (validation_reason IS NULL).

{% set sources = [
  { "name": "bahr_aww_chittaura", "missing": [] },
  { "name": "bahr_aww_fakharpur", "missing": ["Economic_Status"] },
  { "name": "bahr_aww_huzoorpur", "missing": [] },
  { "name": "bahr_aww_jarwal", "missing": [] },
  { "name": "bahr_aww_payagpur", "missing": ["Email_Address"] },
  { "name": "bahr_aww_risia", "missing": [] },
  { "name": "bahr_aww_tejwapur", "missing": [] },
  { "name": "bahr_aww_visheshwarganj", "missing": [] },
  { "name": "bal_aww_balrampur_dehat", "missing": [] },
  { "name": "bal_aww_gandas_bujarg", "missing": [] },
  { "name": "bal_aww_rehra_bazar", "missing": [] },
  { "name": "bal_aww_sriduttganj", "missing": [] },
  { "name": "bal_aww_utraula", "missing": [] },
  { "name": "shraw_aww_ekona", "missing": [] },
  { "name": "shraw_aww_hariharpur_rani", "missing": [] },
] %}

WITH all_rows AS (
{% for src in sources %}
SELECT
  "Unique_ID_of_Aanganwadi_Centre"::VARCHAR AS aww_id,
  "Unique_ID_of_Aanganwadi_Centre"::VARCHAR AS awc_id,
  NULLIF("Name_of_Aanganwadi_Worker", '') AS aww_name,
  'Worker' AS aww_role,
  "Cluster_Code" AS sector_id,
  CASE WHEN "Age__complete_years_" ~ '^\d+$' THEN CAST("Age__complete_years_" AS INTEGER) ELSE NULL END AS age,
  NULLIF("Religion", '') AS religion,
  NULLIF("Social_Category", '') AS social_category,
  NULLIF("Education", '') AS education,
  {{ extract_experience_years('"Years_of_Experience__As_AWWs_"') }} AS exp_years,
  {% if 'Economic_Status' in src.missing %}
    NULL
  {% else %}
    NULLIF("Economic_Status", '')
  {% endif %} AS economic_status,
  NULLIF("Mobile_No", '') AS mobile_no,
  {% if 'Email_Address' in src.missing %}
    NULL
  {% else %}
    NULLIF(NULLIF("Email_Address", 'NA'), '')
  {% endif %} AS email_id,
  current_timestamp AS onboarded_at,
  current_timestamp AS created_at,
  current_timestamp AS updated_at,
  TRUE AS is_active,
  {{ validate_aww_row() }} AS validation_reason
FROM {{ source('staging', src.name) }}

{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
)

SELECT
  aww_id, awc_id, aww_name, aww_role, sector_id, age, religion, social_category,
  education, exp_years, economic_status, mobile_no, email_id, onboarded_at,
  created_at, updated_at, is_active
FROM all_rows
WHERE validation_reason IS NULL
