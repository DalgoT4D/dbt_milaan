--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte2 as (
SELECT
"age_raw",
"sex_raw",
"notes_raw",
"state_raw",
"entered_by",
"status_raw",
"child_id_raw",
"district_raw",
"encounter_id",
"doctor_id_raw",
"source_row_id",
"meeting_id_raw",
"speciality_raw",
"clinic_site_raw",
"doctor_name_raw",
"partner_ngo_raw",
"action_taken_raw",
"household_id_raw",
"last_updated_raw",
"meeting_date_raw",
"meeting_type_raw",
"patient_name_raw",
"duration_mins_raw",
"beneficiary_id_raw",
"follow_up_date_raw",
"referral_source_raw",
"reason_for_visit_raw",
"synthetic_record_flag",
"meeting_start_time_raw",
"diagnosis_or_concern_raw",
"_airbyte_raw_id",
"_airbyte_extracted_at",
"_airbyte_meta",
CASE
    WHEN "status_raw" = 'completed' THEN 'Completed'
    WHEN "status_raw" = 'no show' THEN 'No Show'
    WHEN "status_raw" = 'rescheduled' THEN 'Rescheduled'
    WHEN "status_raw" = 'doctor unavailable' THEN 'Doctor Unavailable'
    ELSE 'Other'
END AS "status_case_demo"
FROM {{source('staging_health', 'raw_clinic_meetings')}}
) , cte1 as (
SELECT *,
      CASE WHEN lower(trim(status_raw)) LIKE '%cancel%' THEN 'Cancelled' WHEN lower(trim(status_raw)) LIKE '%no show%' THEN 'No Show' WHEN lower(trim(status_raw)) LIKE '%resched%' THEN 'Rescheduled' WHEN lower(trim(status_raw)) LIKE '%unavailable%' THEN 'Doctor Unavailable' ELSE initcap(trim(status_raw)) END AS status,
      trim(beneficiary_id_raw) AS beneficiary_id,
      trim(meeting_id_raw) AS meeting_id,
      initcap(trim(clinic_site_raw)) AS clinic_site,
      trim(follow_up_date_raw) AS follow_up_date,
      initcap(trim(state_raw)) AS state,
      initcap(trim(district_raw)) AS district,
      CASE WHEN lower(trim(sex_raw)) IN ('f', 'female') THEN 'Female' WHEN lower(trim(sex_raw)) IN ('m', 'male') THEN 'Male' ELSE 'Unknown' END AS sex,
      CASE WHEN lower(trim(meeting_type_raw)) LIKE '%first%' THEN 'First Visit' WHEN lower(trim(meeting_type_raw)) LIKE '%follow%' THEN 'Follow Up' WHEN lower(trim(meeting_type_raw)) LIKE '%tele%' THEN 'Teleconsult' WHEN lower(trim(meeting_type_raw)) LIKE '%group%' THEN 'Group Clinic' WHEN lower(trim(meeting_type_raw)) LIKE '%home%' THEN 'Home Visit Review' ELSE initcap(trim(meeting_type_raw)) END AS meeting_type,
      (CASE
    WHEN trim(meeting_date_raw) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(meeting_date_raw), '-', 1)::integer, split_part(trim(meeting_date_raw), '-', 2)::integer, split_part(trim(meeting_date_raw), '-', 3)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(meeting_date_raw), '/', 1)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer, split_part(trim(meeting_date_raw), '/', 3)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(meeting_date_raw), '/', 1)::integer > 12
      THEN make_date(split_part(trim(meeting_date_raw), '/', 3)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer, split_part(trim(meeting_date_raw), '/', 1)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(meeting_date_raw), '/', 3)::integer, split_part(trim(meeting_date_raw), '/', 1)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(meeting_date_raw), 'DD-MM-YY')
    WHEN trim(meeting_date_raw) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(meeting_date_raw), 'Dy Mon DD YYYY')
    WHEN trim(meeting_date_raw) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(meeting_date_raw)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(meeting_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END)::text AS meeting_date_text,
      CASE
    WHEN trim(meeting_date_raw) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(meeting_date_raw), '-', 1)::integer, split_part(trim(meeting_date_raw), '-', 2)::integer, split_part(trim(meeting_date_raw), '-', 3)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(meeting_date_raw), '/', 1)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer, split_part(trim(meeting_date_raw), '/', 3)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(meeting_date_raw), '/', 1)::integer > 12
      THEN make_date(split_part(trim(meeting_date_raw), '/', 3)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer, split_part(trim(meeting_date_raw), '/', 1)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(meeting_date_raw), '/', 3)::integer, split_part(trim(meeting_date_raw), '/', 1)::integer, split_part(trim(meeting_date_raw), '/', 2)::integer)
    WHEN trim(meeting_date_raw) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(meeting_date_raw), 'DD-MM-YY')
    WHEN trim(meeting_date_raw) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(meeting_date_raw), 'Dy Mon DD YYYY')
    WHEN trim(meeting_date_raw) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(meeting_date_raw)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(meeting_id_raw, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END AS meeting_date  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1