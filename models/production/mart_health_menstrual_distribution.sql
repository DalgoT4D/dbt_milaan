--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte4 as (
SELECT "age_raw", "notes_raw", "entered_by", "quantity_raw", "source_row_id", "product_type_raw", "stockout_reported_raw", "synthetic_record_flag", "awareness_session_attended_raw", "_airbyte_raw_id", "_airbyte_extracted_at", "_airbyte_meta", "area_raw" AS "area", "unit_raw" AS "distribution_unit", "ward_raw" AS "ward", "state_raw" AS "state", "cluster_raw" AS "cluster", "batch_no_raw" AS "batch_no", "district_raw" AS "district", "partner_ngo_raw" AS "partner_ngo", "receipt_ack_raw" AS "receipt_acknowledgement", "household_id_raw" AS "household_id", "beneficiary_id_raw" AS "beneficiary_id", "distribution_id_raw" AS "distribution_id", "field_worker_id_raw" AS "field_worker_id", "beneficiary_name_raw" AS "beneficiary_name", "donor_or_program_raw" AS "donor_or_program", "beneficiary_group_raw" AS "beneficiary_group", "distribution_date_raw" AS "distribution_date_text", "distribution_channel_raw" AS "distribution_channel"
 FROM {{source('staging_health', 'raw_sanitary_dist')}}
) , cte3 as (
SELECT
"age_raw",
"notes_raw",
"entered_by",
"source_row_id",
"product_type_raw",
"stockout_reported_raw",
"synthetic_record_flag",
"awareness_session_attended_raw",
"_airbyte_raw_id",
"_airbyte_extracted_at",
"_airbyte_meta",
"area",
"distribution_unit",
"ward",
"state",
"cluster",
"batch_no",
"district",
"partner_ngo",
"household_id",
"beneficiary_id",
"distribution_id",
"field_worker_id",
"beneficiary_name",
"donor_or_program",
"beneficiary_group",
"distribution_date_text",
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("quantity_raw", 'NA', '0'), '1 packs', '1'), '1 pack', '1'), '2 packs', '2'), '2 pack', '2'), '3 packs', '3'), '3 pack', '3'), '4 packs', '4'), '4 pack', '4') AS "quantity_clean", REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("distribution_channel", 'anganwadi ', 'anganwadi'), 'ANGANWADI', 'anganwadi'), ' clinic', 'clinic'), ' community session', 'community session'), 'community session ', 'community session'), ' home visit', 'home visit'), 'home visit ', 'home visit'), 'HOME VISIT', 'home visit'), 'school session ', 'school session') AS "distribution_channel_clean", REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("receipt_acknowledgement", 'not available ', 'not available'), 'NOT AVAILABLE', 'not available'), ' signed', 'signed'), 'signed ', 'signed'), 'SIGNED', 'signed'), ' thumbprint', 'thumbprint'), 'THUMBPRINT', 'thumbprint'), ' verbal', 'verbal'), 'verbal ', 'verbal'), 'VERBAL', 'verbal'), 'Yes', 'signed') AS "receipt_acknowledgement_clean"
FROM cte4
) , cte2 as (
SELECT
"age_raw",
"notes_raw",
"entered_by",
"source_row_id",
"product_type_raw",
"stockout_reported_raw",
"synthetic_record_flag",
"awareness_session_attended_raw",
"_airbyte_raw_id",
"_airbyte_extracted_at",
"_airbyte_meta",
"area",
"distribution_unit",
"ward",
"state",
"cluster",
"batch_no",
"district",
"partner_ngo",
"household_id",
"beneficiary_id",
"distribution_id",
"field_worker_id",
"beneficiary_name",
"donor_or_program",
"beneficiary_group",
"distribution_date_text",
"distribution_channel_clean",
"receipt_acknowledgement_clean",
CAST("quantity_clean" AS NUMERIC) AS "quantity_clean"
FROM cte3
) , cte1 as (
SELECT "age_raw",
      "notes_raw",
      "entered_by",
      "source_row_id",
      "product_type_raw",
      "stockout_reported_raw",
      "synthetic_record_flag",
      "awareness_session_attended_raw",
      "_airbyte_raw_id",
      "_airbyte_extracted_at",
      "_airbyte_meta",
      "area",
      "distribution_unit",
      "ward",
      "state",
      "cluster",
      "batch_no",
      "district",
      "partner_ngo",
      "household_id",
      "beneficiary_id",
      "distribution_id",
      "field_worker_id",
      "beneficiary_name",
      "donor_or_program",
      "beneficiary_group",
      "distribution_date_text",
      "quantity_clean" AS "quantity_raw",
      "distribution_channel_clean" AS "distribution_channel",
      "receipt_acknowledgement_clean" AS "receipt_acknowledgement",
      CASE lower(trim(product_type_raw)) WHEN 'sanitary pad packet' THEN 'Sanitary Pads' WHEN 'sanitary pads pack' THEN 'Sanitary Pads' WHEN 'reusable cloth pad kit' THEN 'Reusable Cloth Pad Kit' WHEN 'period hygiene kit' THEN 'Period Hygiene Kit' WHEN 'menstrual cup' THEN 'Menstrual Cup' WHEN 'disposal bags' THEN 'Disposal Bags' ELSE initcap(trim(product_type_raw)) END AS product_type,
      quantity_clean::text AS products_distributed,
      quantity_clean::numeric AS products_distributed_numeric,
      CASE WHEN lower(trim(stockout_reported_raw)) IN ('yes', 'y', 'true', '1') THEN 'Stockout' ELSE 'No Stockout' END AS stockout_reported,
      CASE WHEN lower(trim(awareness_session_attended_raw)) IN ('yes', 'y', 'true', '1') THEN 'true' ELSE 'false' END AS awareness_session_attended,
      (CASE
    WHEN trim(distribution_date_text) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(distribution_date_text), '-', 1)::integer, split_part(trim(distribution_date_text), '-', 2)::integer, split_part(trim(distribution_date_text), '-', 3)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(distribution_date_text), '/', 1)::integer, split_part(trim(distribution_date_text), '/', 2)::integer, split_part(trim(distribution_date_text), '/', 3)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(distribution_date_text), '/', 1)::integer > 12
      THEN make_date(split_part(trim(distribution_date_text), '/', 3)::integer, split_part(trim(distribution_date_text), '/', 2)::integer, split_part(trim(distribution_date_text), '/', 1)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(distribution_date_text), '/', 3)::integer, split_part(trim(distribution_date_text), '/', 1)::integer, split_part(trim(distribution_date_text), '/', 2)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(distribution_date_text), 'DD-MM-YY')
    WHEN trim(distribution_date_text) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(distribution_date_text), 'Dy Mon DD YYYY')
    WHEN trim(distribution_date_text) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(distribution_date_text)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(distribution_id, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END)::text AS distribution_date_normalized,
      CASE
    WHEN trim(distribution_date_text) ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
      THEN make_date(split_part(trim(distribution_date_text), '-', 1)::integer, split_part(trim(distribution_date_text), '-', 2)::integer, split_part(trim(distribution_date_text), '-', 3)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
      THEN make_date(split_part(trim(distribution_date_text), '/', 1)::integer, split_part(trim(distribution_date_text), '/', 2)::integer, split_part(trim(distribution_date_text), '/', 3)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' AND split_part(trim(distribution_date_text), '/', 1)::integer > 12
      THEN make_date(split_part(trim(distribution_date_text), '/', 3)::integer, split_part(trim(distribution_date_text), '/', 2)::integer, split_part(trim(distribution_date_text), '/', 1)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
      THEN make_date(split_part(trim(distribution_date_text), '/', 3)::integer, split_part(trim(distribution_date_text), '/', 1)::integer, split_part(trim(distribution_date_text), '/', 2)::integer)
    WHEN trim(distribution_date_text) ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
      THEN to_date(trim(distribution_date_text), 'DD-MM-YY')
    WHEN trim(distribution_date_text) ~ '^[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{4}$'
      THEN to_date(trim(distribution_date_text), 'Dy Mon DD YYYY')
    WHEN trim(distribution_date_text) ~ '^[0-9]+([.][0-9]+)?$'
      THEN date '1899-12-30' + floor(trim(distribution_date_text)::numeric)::integer
    ELSE make_date(2026, ((coalesce(nullif(regexp_replace(distribution_id, '[^0-9]', '', 'g'), ''), '1')::integer - 1) % 12) + 1, 15)
  END AS distribution_date,
      CASE
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '') IS NULL THEN 'Unknown'
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '')::numeric < 15 THEN 'Under 15'
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '')::numeric < 20 THEN '15-19'
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '')::numeric < 25 THEN '20-24'
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '')::numeric < 35 THEN '25-34'
        WHEN NULLIF(REGEXP_REPLACE(COALESCE(age_raw, ''), '[^0-9.]', '', 'g'), '')::numeric < 45 THEN '35-44'
        ELSE '45+'
      END AS age_group  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1