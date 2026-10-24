{#
  Macro to unpivot attendance data from a single source.
  Assumes all tables have Session_name_1 through Session_name_12 columns.
#}

{% macro unpivot_attendance(source_name) %}
SELECT
  "Aaganwadi_CenterCode"::VARCHAR AS awc_id,
  session_id,
  session_date,
  session_value
FROM {{ source('staging', source_name) }}
CROSS JOIN LATERAL (
  VALUES
    ('session_1', (DATE '2026-03-01'), COALESCE("Session_name_1", '')),
    ('session_2', (DATE '2026-04-01'), COALESCE("Session_name_2", '')),
    ('session_3', (DATE '2026-05-01'), COALESCE("Session_name_3", '')),
    ('session_4', (DATE '2026-06-01'), COALESCE("Session_name_4", '')),
    ('session_5', (DATE '2026-07-01'), COALESCE("Session_name_5", '')),
    ('session_6', (DATE '2026-08-01'), COALESCE("Session_name_6", '')),
    ('session_7', (DATE '2026-09-01'), COALESCE("Session_name_7", '')),
    ('session_8', (DATE '2026-10-01'), COALESCE("Session_name_8", '')),
    ('session_9', (DATE '2026-11-01'), COALESCE("Session_name_9", '')),
    ('session_10', (DATE '2026-12-01'), COALESCE("Session_name_10", '')),
    ('session_11', (DATE '2027-01-01'), COALESCE("Session_name_11", '')),
    ('session_12', (DATE '2027-02-01'), COALESCE("Session_name_12", ''))
) AS sessions(session_id, session_date, session_value)
WHERE session_value NOT IN ('', 'None') AND session_value IS NOT NULL
{% endmacro %}
