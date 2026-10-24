{{ config(materialized='table', schema='staging_intermediate') }}

-- Unpivot each AWW attendance source individually, then union all results.
-- Converts session columns into rows: session_id, session_date, session_value.

{% set sources_12_sessions = [
  'bahr_aww_att_chittaura',
  'bahr_aww_att_fakharpur',
  'bahr_aww_att_huzurpur',
  'bahr_aww_att_jarwal',
  'bahr_aww_att_payagpur',
  'bahr_aww_att_risiya',
  'bahr_aww_att_tejwapur',
  'bahr_aww_att_visheshwarganj',
] %}

{% set sources_11_sessions = [
  'bal_aww_att_balrampur_dehat',
  'bal_aww_att_gandas_bujarg',
  'bal_aww_att_rehra_bazar',
  'bal_aww_att_utraula',
  'shraw_aww_att_ekona',
  'shraw_aww_att_hariharpur_rani',
] %}

{% for src_name in sources_12_sessions %}
SELECT
  "Aaganwadi_CenterCode"::VARCHAR AS awc_id,
  session_id,
  session_date,
  session_value
FROM {{ source('staging', src_name) }}
CROSS JOIN LATERAL (
  VALUES
    ('session_1', (DATE '2026-03-01'), "Session_name_1"),
    ('session_2', (DATE '2026-04-01'), "Session_name_2"),
    ('session_3', (DATE '2026-05-01'), "Session_name_3"),
    ('session_4', (DATE '2026-06-01'), "Session_name_4"),
    ('session_5', (DATE '2026-07-01'), "Session_name_5"),
    ('session_6', (DATE '2026-08-01'), "Session_name_6"),
    ('session_7', (DATE '2026-09-01'), "Session_name_7"),
    ('session_8', (DATE '2026-10-01'), "Session_name_8"),
    ('session_9', (DATE '2026-11-01'), "Session_name_9"),
    ('session_10', (DATE '2026-12-01'), "Session_name_10"),
    ('session_11', (DATE '2027-01-01'), "Session_name_11"),
    ('session_12', (DATE '2027-02-01'), "Session_name_12")
) AS sessions(session_id, session_date, session_value)
WHERE session_value NOT IN ('', 'None') AND session_value IS NOT NULL
UNION ALL
{% endfor %}

{% for src_name in sources_11_sessions %}
SELECT
  "Aaganwadi_CenterCode"::VARCHAR AS awc_id,
  session_id,
  session_date,
  session_value
FROM {{ source('staging', src_name) }}
CROSS JOIN LATERAL (
  VALUES
    ('session_1', (DATE '2026-03-01'), "Session_name_1"),
    ('session_2', (DATE '2026-04-01'), "Session_name_2"),
    ('session_3', (DATE '2026-05-01'), "Session_name_3"),
    ('session_4', (DATE '2026-06-01'), "Session_name_4"),
    ('session_5', (DATE '2026-07-01'), "Session_name_5"),
    ('session_6', (DATE '2026-08-01'), "Session_name_6"),
    ('session_7', (DATE '2026-09-01'), "Session_name_7"),
    ('session_8', (DATE '2026-10-01'), "Session_name_8"),
    ('session_9', (DATE '2026-11-01'), "Session_name_9"),
    ('session_10', (DATE '2026-12-01'), "Session_name_10"),
    ('session_11', (DATE '2027-01-01'), "Session_name_11")
) AS sessions(session_id, session_date, session_value)
WHERE session_value NOT IN ('', 'None') AND session_value IS NOT NULL
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
