{#
  Macro to validate AWW row and return error reason, or NULL if valid.

  Usage:
    SELECT
      aww_id,
      aww_name,
      {{ validate_aww_row() }} AS validation_reason
    FROM source
#}

{% macro validate_aww_row() %}
CASE
  WHEN "Unique_ID_of_Aanganwadi_Centre" IS NULL OR "Unique_ID_of_Aanganwadi_Centre" = ''
    THEN 'Empty Unique ID'
  WHEN "Age__complete_years_" IS NOT NULL AND "Age__complete_years_" != '' AND "Age__complete_years_" !~ '^\d+$'
    THEN 'Failed because invalid value in Age__complete_years_. Value - ' || "Age__complete_years_"
  WHEN "Years_of_Experience__As_AWWs_" IS NOT NULL
    AND "Years_of_Experience__As_AWWs_" != ''
    AND "Years_of_Experience__As_AWWs_" !~ '^\d+(\.\d+)?$'
    AND UPPER("Years_of_Experience__As_AWWs_") NOT LIKE '%MONTH%'
    AND UPPER("Years_of_Experience__As_AWWs_") NOT LIKE '%M'
    AND UPPER("Years_of_Experience__As_AWWs_") NOT LIKE '%YEAR%'
    AND UPPER("Years_of_Experience__As_AWWs_") NOT LIKE '%Y'
    THEN 'Failed because invalid value in Years_of_Experience__As_AWWs_. Value - ' || "Years_of_Experience__As_AWWs_"
  ELSE NULL
END
{% endmacro %}
