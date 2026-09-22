--DBT AUTOMATION has generated this model, please DO NOT EDIT 
--Please make sure you dont change the model name 

{{ config(materialized='table', schema='silver') }}
WITH cte1 as (

SELECT "t1"."_airbyte_extracted_at",
"t1"."_airbyte_generation_id",
"t1"."_airbyte_meta",
"t1"."_airbyte_raw_id",
"t1"."Aaganwadi_Center_Code",
"t1"."Aaganwadi_Center_Name",
"t1"."Block_Code",
"t1"."Block_Name",
"t1"."District_Code",
"t1"."District_Name",
"t1"."Gram_Panchayat_Code",
"t1"."Gram_Panchayat_Name",
"t1"."Sector_Code",
"t1"."Sector_Name",
"t1"."State_Code",
"t1"."State_Name",
"t1"."Village_Code",
"t1"."Village_Name",
"t2"."_airbyte_raw_id" AS "_airbyte_raw_id_2",
"t2"."_airbyte_extracted_at" AS "_airbyte_extracted_at_2",
"t2"."_airbyte_meta" AS "_airbyte_meta_2",
"t2"."_airbyte_generation_id" AS "_airbyte_generation_id_2",
"t2"."Religion",
"t2"."Education",
"t2"."Mobile_No",
"t2"."Block_Code" AS "Block_Code_2",
"t2"."Block_Name" AS "Block_Name_2",
"t2"."State_Code" AS "State_Code_2",
"t2"."State_Name" AS "State_Name_2",
"t2"."Sector_Code" AS "Sector_Code_2",
"t2"."Sector_Name" AS "Sector_Name_2",
"t2"."Village_Code" AS "Village_Code_2",
"t2"."Village_Name" AS "Village_Name_2",
"t2"."District_Code" AS "District_Code_2",
"t2"."District_Name" AS "District_Name_2",
"t2"."Email_Address",
"t2"."Economic_Status",
"t2"."Social_Category",
"t2"."Gram_Panchayat_Code" AS "Gram_Panchayat_Code_2",
"t2"."Gram_Panchayat_Name" AS "Gram_Panchayat_Name_2",
"t2"."Aaganwadi_CenterCode",
"t2"."Age__complete_years_",
"t2"."Aaganwadi_Center_Name" AS "Aaganwadi_Center_Name_2",
"t2"."Name_of_Aanganwadi_Worker",
"t2"."Years_of_Experience__As_AWWs_"
 FROM {{source('bronze', 'master_data_gip_30_all_15_blocks_v2')}} t1
 LEFT JOIN {{source('bronze', 'Compile_data')}} t2
 ON "t1"."Aaganwadi_Center_Code" = "t2"."Aaganwadi_CenterCode"
)
-- Final SELECT statement combining the outputs of all CTEs
SELECT *
FROM cte1