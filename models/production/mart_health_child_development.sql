--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte2 as (
SELECT
"sex_raw",
"area_raw",
"ward_raw",
"notes_raw",
"state_raw",
"entered_by",
"child_id_raw",
"district_raw",
"severity_raw",
"diagnosis_raw",
"mother_id_raw",
"source_row_id",
"age_months_raw",
"child_name_raw",
"visit_date_raw",
"case_status_raw",
"partner_ngo_raw",
"tracking_id_raw",
"household_id_raw",
"social_score_raw",
"school_status_raw",
"screening_tool_raw",
"assistive_device_raw",
"fine_motor_score_raw",
"next_review_date_raw",
"therapy_referred_raw",
"gross_motor_score_raw",
"synthetic_record_flag",
"home_program_given_raw",
"communication_score_raw",
"caregiver_beneficiary_id_raw",
"linked_clinic_meeting_id_raw",
"sessions_attended_last_month_raw",
"_airbyte_raw_id",
"_airbyte_extracted_at",
"_airbyte_meta",
CASE
    WHEN "sex_raw" = 'F' THEN 'Female'
    WHEN "sex_raw" = 'M' THEN 'Male'
    ELSE 'Other'
END AS "sex_case_demo"
FROM {{source('staging_health', 'raw_child_dev_tracking')}}
) , cte1 as (
SELECT *,
      trim(age_months_raw) AS age_months_source,
      CASE WHEN lower(trim(age_months_raw)) LIKE '%year%' THEN (nullif(regexp_replace(age_months_raw, '[^0-9]', '', 'g'), '')::integer * 12)::text ELSE nullif(regexp_replace(age_months_raw, '[^0-9]', '', 'g'), '') END AS age_months_clean,
      initcap(trim(area_raw)) AS area,
      upper(trim(ward_raw)) AS ward,
      initcap(trim(state_raw)) AS state,
      initcap(trim(district_raw)) AS district,
      trim(child_id_raw) AS child_id,
      initcap(trim(child_name_raw)) AS child_name,
      trim(mother_id_raw) AS mother_id,
      trim(household_id_raw) AS household_id,
      trim(caregiver_beneficiary_id_raw) AS caregiver_beneficiary_id,
      initcap(trim(partner_ngo_raw)) AS partner_ngo,
      trim(tracking_id_raw) AS tracking_id,
      CASE WHEN lower(trim(sex_raw)) IN ('f', 'female') THEN 'Female' WHEN lower(trim(sex_raw)) IN ('m', 'male') THEN 'Male' ELSE 'Other' END AS sex_clean,
      CASE WHEN lower(trim(sex_raw)) IN ('f', 'female') THEN 'Female' WHEN lower(trim(sex_raw)) IN ('m', 'male') THEN 'Male' ELSE 'Other' END AS sex,
      trim(severity_raw) AS severity_source,
      CASE WHEN lower(trim(severity_raw)) = 'at risk' THEN 'At Risk' ELSE initcap(trim(severity_raw)) END AS severity,
      trim(diagnosis_raw) AS diagnosis_source,
      initcap(trim(diagnosis_raw)) AS diagnosis,
      trim(therapy_referred_raw) AS therapy_referral_source,
      initcap(trim(therapy_referred_raw)) AS therapy_referral,
      CASE WHEN lower(trim(therapy_referred_raw)) IN ('none', '') OR therapy_referred_raw IS NULL THEN 'false' ELSE 'true' END AS therapy_referred_text,
      trim(case_status_raw) AS case_status_source,
      initcap(replace(trim(case_status_raw), '-', ' ')) AS case_status,
      trim(screening_tool_raw) AS screening_tool_source,
      CASE lower(replace(trim(screening_tool_raw), ' ', '-')) WHEN 'asq-3' THEN 'ASQ-3' WHEN 'm-chat-r' THEN 'M-CHAT-R' WHEN 'inclen' THEN 'INCLEN' ELSE initcap(trim(screening_tool_raw)) END AS screening_tool,
      trim(school_status_raw) AS school_status_source,
      initcap(trim(school_status_raw)) AS school_status,
      trim(social_score_raw) AS social_score_source,
      trim(fine_motor_score_raw) AS fine_motor_score_source,
      trim(gross_motor_score_raw) AS gross_motor_score_source,
      trim(communication_score_raw) AS communication_score_source,
      trim(sessions_attended_last_month_raw) AS sessions_attended_source,
      trim(next_review_date_raw) AS next_review_date_source,
      trim(visit_date_raw) AS visit_date_source,
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
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(tracking_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END)::text AS visit_date_clean1,
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
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(tracking_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
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
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(tracking_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END AS visit_date  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1