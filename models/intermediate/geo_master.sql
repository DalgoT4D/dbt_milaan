{{ config(materialized='table', schema='intermediate') }}

WITH mapped AS (

    SELECT
        CAST("Aaganwadi_Center_Code" AS VARCHAR) AS awc_id,
        "Aaganwadi_Center_Name"                  AS awc_name,
        CAST("Sector_Code" AS VARCHAR)           AS sector_id,
        "Sector_Name"                             AS sector_name,
        CAST("Block_Code" AS VARCHAR)             AS block_id,
        "Block_Name"                              AS block_name,
        CAST("District_Code" AS VARCHAR)          AS district_id,
        "District_Name"                           AS district_name,
        CAST("State_Code" AS VARCHAR)             AS state_id,
        "State_Name"                              AS state_name,
        current_timestamp                         AS created_at,
        current_timestamp                         AS updated_at,
        TRUE                                      AS is_active
    FROM {{ source('staging', 'master_geo') }}

)

SELECT *
FROM mapped
