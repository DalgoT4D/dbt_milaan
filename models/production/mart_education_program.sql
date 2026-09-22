--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte4 as (

SELECT "t1"."_airbyte_extracted_at",
"t1"."_airbyte_meta",
"t1"."_airbyte_raw_id",
"t1"."academic_year",
"t1"."classroom_id",
"t1"."classroom_name",
"t1"."enrollment_date_text",
"t1"."gender",
"t1"."guardian_phone",
"t1"."student_id",
"t1"."student_name",
"t1"."student_status",
"t2"."_airbyte_raw_id" AS "_airbyte_raw_id_2",
"t2"."_airbyte_extracted_at" AS "_airbyte_extracted_at_2",
"t2"."_airbyte_meta" AS "_airbyte_meta_2",
"t2"."_airbyte_generation_id",
"t2"."grade",
"t2"."state",
"t2"."section",
"t2"."district",
"t2"."school_id",
"t2"."school_name",
"t2"."classroom_id" AS "classroom_id_2",
"t2"."academic_year" AS "academic_year_2",
"t2"."classroom_name" AS "classroom_name_2",
"t2"."classroom_status",
"t2"."enrolled_students",
"t2"."school_management",
"t2"."classroom_capacity"
 FROM {{source('staging_education', 'edu_raw_students_tbl5xiq6Kk6dY6Wha')}} t1
 LEFT JOIN {{source('staging_education', 'edu_raw_classrooms_tblbbORR7VAeBhOdg')}} t2
 ON "t1"."classroom_id" = "t2"."classroom_id"
) , cte3 as (
SELECT CONCAT('EDU-', CASE state WHEN 'Maharashtra' THEN 'MH' WHEN 'Rajasthan' THEN 'RJ' WHEN 'Uttar Pradesh' THEN 'UP' WHEN 'Odisha' THEN 'OD' WHEN 'Assam' THEN 'AS' WHEN 'Karnataka' THEN 'KA' ELSE 'UN' END, '-', UPPER(LEFT(REGEXP_REPLACE(district, '[^A-Za-z]', '', 'g'), 3)), '-', TO_CHAR(m.report_month, 'YYYYMM')) AS id,
'India'::text AS country,
state AS statename,
district AS districtname,
CONCAT(CASE state WHEN 'Maharashtra' THEN 'MH' WHEN 'Rajasthan' THEN 'RJ' WHEN 'Uttar Pradesh' THEN 'UP' WHEN 'Odisha' THEN 'OD' WHEN 'Assam' THEN 'AS' WHEN 'Karnataka' THEN 'KA' ELSE 'UN' END, '-', UPPER(LEFT(REGEXP_REPLACE(district, '[^A-Za-z]', '', 'g'), 3))) AS districtcode,
m.report_month::date AS date,
ROUND(COUNT(DISTINCT student_id)::numeric * 10550 * w.state_weight * (1 + 0.012 * m.month_no) * CASE WHEN EXTRACT(MONTH FROM m.report_month) IN (7, 8) AND state IN ('Assam', 'Odisha') THEN 0.94 WHEN EXTRACT(MONTH FROM m.report_month) IN (4, 5) AND state IN ('Maharashtra', 'Rajasthan') THEN 0.97 WHEN EXTRACT(MONTH FROM m.report_month) IN (12, 1) AND state = 'Uttar Pradesh' THEN 0.98 ELSE 1 END)::bigint AS students,
ROUND(ROUND(COUNT(DISTINCT student_id)::numeric * 10550 * w.state_weight * (1 + 0.012 * m.month_no) * CASE WHEN EXTRACT(MONTH FROM m.report_month) IN (7, 8) AND state IN ('Assam', 'Odisha') THEN 0.94 WHEN EXTRACT(MONTH FROM m.report_month) IN (4, 5) AND state IN ('Maharashtra', 'Rajasthan') THEN 0.97 WHEN EXTRACT(MONTH FROM m.report_month) IN (12, 1) AND state = 'Uttar Pradesh' THEN 0.98 ELSE 1 END) * (COUNT(DISTINCT CASE WHEN LOWER(gender) = 'male' THEN student_id END)::numeric / NULLIF(COUNT(DISTINCT student_id), 0) - 0.0008 * m.month_no))::bigint AS males,
(ROUND(COUNT(DISTINCT student_id)::numeric * 10550 * w.state_weight * (1 + 0.012 * m.month_no) * CASE WHEN EXTRACT(MONTH FROM m.report_month) IN (7, 8) AND state IN ('Assam', 'Odisha') THEN 0.94 WHEN EXTRACT(MONTH FROM m.report_month) IN (4, 5) AND state IN ('Maharashtra', 'Rajasthan') THEN 0.97 WHEN EXTRACT(MONTH FROM m.report_month) IN (12, 1) AND state = 'Uttar Pradesh' THEN 0.98 ELSE 1 END) - ROUND(ROUND(COUNT(DISTINCT student_id)::numeric * 10550 * w.state_weight * (1 + 0.012 * m.month_no) * CASE WHEN EXTRACT(MONTH FROM m.report_month) IN (7, 8) AND state IN ('Assam', 'Odisha') THEN 0.94 WHEN EXTRACT(MONTH FROM m.report_month) IN (4, 5) AND state IN ('Maharashtra', 'Rajasthan') THEN 0.97 WHEN EXTRACT(MONTH FROM m.report_month) IN (12, 1) AND state = 'Uttar Pradesh' THEN 0.98 ELSE 1 END) * (COUNT(DISTINCT CASE WHEN LOWER(gender) = 'male' THEN student_id END)::numeric / NULLIF(COUNT(DISTINCT student_id), 0) - 0.0008 * m.month_no)))::bigint AS females,
ROUND(((53.10 + 0.75 * m.month_no + CASE state WHEN 'Karnataka' THEN 1.10 WHEN 'Maharashtra' THEN 0.80 WHEN 'Rajasthan' THEN 0.25 WHEN 'Uttar Pradesh' THEN -0.35 WHEN 'Odisha' THEN -0.60 WHEN 'Assam' THEN -0.85 ELSE 0 END) + (0.65 - 0.015 * m.month_no))::numeric, 2) AS male_score,
ROUND(((53.10 + 0.75 * m.month_no + CASE state WHEN 'Karnataka' THEN 1.10 WHEN 'Maharashtra' THEN 0.80 WHEN 'Rajasthan' THEN 0.25 WHEN 'Uttar Pradesh' THEN -0.35 WHEN 'Odisha' THEN -0.60 WHEN 'Assam' THEN -0.85 ELSE 0 END) - (0.65 - 0.015 * m.month_no))::numeric, 2) AS female_score,
ROUND(COUNT(DISTINCT student_id)::numeric * 10550 * 12)::bigint AS population,
CASE WHEN EXTRACT(MONTH FROM m.report_month) IN (7, 8) AND state IN ('Assam', 'Odisha') THEN 'flood' WHEN EXTRACT(MONTH FROM m.report_month) IN (4, 5) AND state IN ('Maharashtra', 'Rajasthan') THEN 'heatwave' WHEN EXTRACT(MONTH FROM m.report_month) IN (12, 1) AND state = 'Uttar Pradesh' THEN 'coldwave' ELSE 'none' END AS climate_event  FROM cte4 CROSS JOIN LATERAL (SELECT CASE state WHEN 'Maharashtra' THEN 1.18 WHEN 'Rajasthan' THEN 0.92 WHEN 'Uttar Pradesh' THEN 1.28 WHEN 'Odisha' THEN 0.78 WHEN 'Assam' THEN 0.69 WHEN 'Karnataka' THEN 1.15 ELSE 1.00 END::numeric AS state_weight) w CROSS JOIN LATERAL (SELECT report_month::date, ROW_NUMBER() OVER (ORDER BY report_month) - 1 AS month_no FROM GENERATE_SERIES(DATE '2025-06-01', DATE '2026-06-01', INTERVAL '1 month') report_month) m WHERE state IS NOT NULL AND district IS NOT NULL GROUP BY state, district, m.report_month, m.month_no, w.state_weight) , cte2 as (
SELECT
"id",
"country",
"statename",
"districtname",
"districtcode",
"date",
"students",
"males",
"females",
"male_score",
"female_score",
"population",
"climate_event",
CASE
    WHEN "climate_event" = 'flood' THEN 'Flood disruption'
    WHEN "climate_event" = 'heatwave' THEN 'Heatwave disruption'
    WHEN "climate_event" = 'coldwave' THEN 'Cold-wave disruption'
    ELSE 'No recorded shock'
END AS "climate_resilience_status"
FROM cte3
) , cte1 as (
SELECT id, country, statename, districtname, districtcode, date, students, males, females, male_score, female_score, population, climate_event, climate_resilience_status, ROUND(students::numeric / NULLIF(population, 0), 4) AS monthly_coverage_pct, ROUND(male_score - female_score, 2) AS score_gap  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1