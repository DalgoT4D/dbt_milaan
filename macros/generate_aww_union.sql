{#
  Macro to dynamically generate UNION query for AWW files based on hardcoded config.

  Usage in a model:
    {{ generate_aww_union() }}

  The macro defines file metadata and generates:
  - One CTE per CSV file
  - Column mappings with NULL defaults for missing columns
  - Standard transformations (CAST, NULLIF, etc.)
  - Final UNION ALL combining all CTEs
#}

{% macro generate_aww_union() %}

{% set files = [
  { "name": "aww_chittaura", "path": "/Users/prxgyx/Downloads/Raw data/aww_chittaura.csv", "missing": [] },
  { "name": "aww_fakharpur", "path": "/Users/prxgyx/Downloads/Raw data/aww_fakharpur.csv", "missing": ["Economic Status"] },
  { "name": "aww_huzoorpur", "path": "/Users/prxgyx/Downloads/Raw data/aww_huzoorpur.csv", "missing": [] },
  { "name": "aww_jarwal", "path": "/Users/prxgyx/Downloads/Raw data/aww_jarwal.csv", "missing": [] },
  { "name": "aww_payagpur", "path": "/Users/prxgyx/Downloads/Raw data/aww_payagpur.csv", "missing": ["Email Address"] },
  { "name": "aww_risia", "path": "/Users/prxgyx/Downloads/Raw data/aww_risia.csv", "missing": [] },
  { "name": "aww_tejwapur", "path": "/Users/prxgyx/Downloads/Raw data/aww_tejwapur.csv", "missing": [] },
  { "name": "aww_visheshwarganj", "path": "/Users/prxgyx/Downloads/Raw data/aww_visheshwarganj.csv", "missing": [] },
  { "name": "aww_balrampur_dehat", "path": "/Users/prxgyx/Downloads/Raw data/aww_balrampur_dehat.csv", "missing": [] },
  { "name": "aww_ekona", "path": "/Users/prxgyx/Downloads/Raw data/aww_ekona.csv", "missing": [] },
  { "name": "aww_gandas_bujarg", "path": "/Users/prxgyx/Downloads/Raw data/aww_gandas_bujarg.csv", "missing": [] },
  { "name": "aww_hariharpur_rani", "path": "/Users/prxgyx/Downloads/Raw data/aww_hariharpur_rani.csv", "missing": [] },
  { "name": "aww_rehra_bazar", "path": "/Users/prxgyx/Downloads/Raw data/aww_rehra_bazar.csv", "missing": [] },
  { "name": "aww_sriduttganj", "path": "/Users/prxgyx/Downloads/Raw data/aww_sriduttganj.csv", "missing": [] },
  { "name": "aww_utraula", "path": "/Users/prxgyx/Downloads/Raw data/aww_utraula.csv", "missing": [] },
] %}

{% for file in files %}
{% if loop.first %}WITH {% endif %}
{{ file.name }} AS (
  SELECT
    CAST("Unique ID of Aanganwadi Centre" AS VARCHAR) AS aww_id,
    CAST("Unique ID of Aanganwadi Centre" AS VARCHAR) AS awc_id,
    NULLIF("Name of Aanganwadi Worker", '') AS aww_name,
    'Worker' AS aww_role,
    "Cluster Code" AS sector_id,
    TRY_CAST("Age (complete years)" AS INTEGER) AS age,
    NULLIF("Religion", '') AS religion,
    NULLIF("Social Category", '') AS social_category,
    NULLIF("Education", '') AS education,
    TRY_CAST("Years of Experience (As AWWs)" AS INTEGER) AS exp_years,
    {% if 'Economic Status' in file.missing %}
      NULL
    {% else %}
      NULLIF("Economic Status", '')
    {% endif %} AS economic_status,
    NULLIF("Mobile No", '') AS mobile_no,
    {% if 'Email Address' in file.missing %}
      NULL
    {% else %}
      NULLIF(NULLIF("Email Address", 'NA'), '')
    {% endif %} AS email_id,
    DATE '2026-05-01' AS onboarded_at,
    current_timestamp AS created_at,
    current_timestamp AS updated_at,
    TRUE AS is_active
  FROM read_csv_auto('{{ file.path }}', header = true, all_varchar = true)
  WHERE "Unique ID of Aanganwadi Centre" != '' AND "Unique ID of Aanganwadi Centre" IS NOT NULL
)
{{ "," if not loop.last else "" }}

{% endfor %}

SELECT * FROM {{ files[0].name }}
{% for file in files[1:] %}
UNION ALL SELECT * FROM {{ file.name }}
{% endfor %}

{% endmacro %}
