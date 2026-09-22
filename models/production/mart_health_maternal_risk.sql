--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte2 as (
SELECT
"bmi_raw",
"edd_raw",
"area_raw",
"ward_raw",
"notes_raw",
"state_raw",
"parity_raw",
"gravida_raw",
"district_raw",
"lmp_date_raw",
"visit_id_raw",
"age_years_raw",
"mother_id_raw",
"source_row_id",
"risk_level_raw",
"visit_date_raw",
"bp_systolic_raw",
"case_status_raw",
"mother_name_raw",
"partner_ngo_raw",
"bp_diastolic_raw",
"danger_signs_raw",
"household_id_raw",
"pregnancy_id_raw",
"anemia_status_raw",
"beneficiary_id_raw",
"field_worker_id_raw",
"hemoglobin_g_dl_raw",
"next_visit_date_raw",
"prior_c_section_raw",
"referral_status_raw",
"hypertension_flag_raw",
"referred_facility_raw",
"synthetic_record_flag",
"transport_support_raw",
"gestational_age_weeks_raw",
"_airbyte_raw_id",
"_airbyte_extracted_at",
"_airbyte_meta",
CASE
    WHEN "risk_level_raw" = 'critical' THEN 'Critical'
    WHEN "risk_level_raw" = 'high' THEN 'High'
    WHEN "risk_level_raw" = 'moderate' THEN 'Moderate'
    WHEN "risk_level_raw" = 'low' THEN 'Low'
    ELSE 'Unknown'
END AS "risk_level_case_demo"
FROM {{source('staging_health', 'raw_maternal_risk')}}
) , cte1 as (
SELECT *,
      CASE lower(trim(risk_level_raw)) WHEN 'critical' THEN 'Critical' WHEN 'high' THEN 'High' WHEN 'moderate' THEN 'Moderate' WHEN 'low' THEN 'Low' ELSE 'Unknown' END AS risk_level,
      trim(beneficiary_id_raw) AS beneficiary_id,
      trim(mother_id_raw) AS mother_id,
      trim(visit_id_raw) AS visit_id,
      trim(referred_facility_raw) AS referred_facility,
      initcap(trim(state_raw)) AS state,
      initcap(trim(district_raw)) AS district,
      initcap(replace(trim(referral_status_raw), '_', ' ')) AS referral_status,
      (CASE
    WHEN trim(visit_date_raw) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(visit_date_raw), '-', 1)::integer, split_part(trim(visit_date_raw), '-', 2)::integer, split_part(trim(visit_date_raw), '-', 3)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(visit_date_raw), '/', 1)::integer, split_part(trim(visit_date_raw), '/', 2)::integer, split_part(trim(visit_date_raw), '/', 3)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(visit_date_raw), '/', 1)::integer > 12
      THEN make_date(split_part(trim(visit_date_raw), '/', 3)::integer, split_part(trim(visit_date_raw), '/', 2)::integer, split_part(trim(visit_date_raw), '/', 1)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(visit_date_raw), '/', 3)::integer, split_part(trim(visit_date_raw), '/', 1)::integer, split_part(trim(visit_date_raw), '/', 2)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(visit_date_raw), 'DD-MM-YY')
    WHEN trim(visit_date_raw) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(visit_date_raw), 'Dy Mon DD YYYY')
    WHEN trim(visit_date_raw) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(visit_date_raw)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(visit_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END)::text AS visit_date_text,
      CASE
    WHEN trim(visit_date_raw) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(visit_date_raw), '-', 1)::integer, split_part(trim(visit_date_raw), '-', 2)::integer, split_part(trim(visit_date_raw), '-', 3)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(visit_date_raw), '/', 1)::integer, split_part(trim(visit_date_raw), '/', 2)::integer, split_part(trim(visit_date_raw), '/', 3)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(visit_date_raw), '/', 1)::integer > 12
      THEN make_date(split_part(trim(visit_date_raw), '/', 3)::integer, split_part(trim(visit_date_raw), '/', 2)::integer, split_part(trim(visit_date_raw), '/', 1)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(visit_date_raw), '/', 3)::integer, split_part(trim(visit_date_raw), '/', 1)::integer, split_part(trim(visit_date_raw), '/', 2)::integer)
    WHEN trim(visit_date_raw) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(visit_date_raw), 'DD-MM-YY')
    WHEN trim(visit_date_raw) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(visit_date_raw), 'Dy Mon DD YYYY')
    WHEN trim(visit_date_raw) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(visit_date_raw)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(visit_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END AS visit_date  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1