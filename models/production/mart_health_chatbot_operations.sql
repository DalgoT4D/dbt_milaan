--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='production') }}
WITH cte2 as (
SELECT "state_raw", "intent_raw", "channel_raw", "consent_raw", "child_id_raw", "district_raw", "language_raw", "mother_id_raw", "sentiment_raw", "source_row_id", "session_id_raw", "bot_version_raw", "partner_ngo_raw", "household_id_raw", "message_count_raw", "beneficiary_id_raw", "interaction_id_raw", "interaction_ts_raw", "free_text_topic_raw", "linked_record_id_raw", "escalation_reason_raw", "handoff_worker_id_raw", "intent_confidence_raw", "resolution_status_raw", "synthetic_record_flag", "escalated_to_human_raw", "linked_record_type_raw", "first_response_seconds_raw", "_airbyte_raw_id", "_airbyte_extracted_at", "_airbyte_meta"
FROM {{ source('staging_health', 'raw_chatbot_interactions') }}
) , cte1 as (
SELECT *,
      trim(beneficiary_id_raw) AS beneficiary_id,
      trim(interaction_id_raw) AS interaction_id,
      trim(interaction_ts_raw) AS interaction_timestamp,
      initcap(trim(district_raw)) AS district,
      initcap(trim(state_raw)) AS state,
      initcap(trim(intent_raw)) AS intent,
      initcap(trim(language_raw)) AS language,
      initcap(trim(resolution_status_raw)) AS resolution_status,
      CASE WHEN lower(trim(escalated_to_human_raw)) IN ('yes', 'y', 'true', '1') THEN 'true' ELSE 'false' END AS escalated_to_human,
      CASE WHEN escalation_reason_raw IS NULL OR trim(escalation_reason_raw) = '' THEN 'Not Applicable' ELSE initcap(trim(escalation_reason_raw)) END AS escalation_reason,
      CASE lower(trim(channel_raw)) WHEN 'sms' THEN 'SMS' WHEN 'ivr' THEN 'IVR' WHEN 'whatsapp' THEN 'WhatsApp' ELSE initcap(trim(channel_raw)) END AS channel  FROM cte2)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1