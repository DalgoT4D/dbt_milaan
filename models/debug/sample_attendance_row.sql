-- Show sample attendance data structure

SELECT
  "Aaganwadi_CenterCode",
  "Block_Name",
  "District_Name",
  "Session_name_1",
  "Session_name_2",
  "Session_name_3",
  "Session_name_4",
  "Session_name_5",
  "Session_name_6",
  "Session_name_7",
  "Session_name_8"
FROM {{ source('staging', 'bahr_aww_att_chittaura') }}
LIMIT 3
