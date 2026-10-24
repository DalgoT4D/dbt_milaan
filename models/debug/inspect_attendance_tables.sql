-- Temporary model to inspect bal and shraw attendance table structures

{% set tables_to_inspect = [
  ('staging', 'bal_aww_att_balrampur_dehat'),
  ('staging', 'bal_aww_att_gandas_bujarg'),
  ('staging', 'bal_aww_att_rehra_bazar'),
  ('staging', 'bal_aww_att_sriduttganj'),
  ('staging', 'bal_aww_att_utraula'),
  ('staging', 'shraw_aww_att_ekona'),
  ('staging', 'shraw_aww_att_hariharpur_rani'),
] %}

{% for schema, table in tables_to_inspect %}
  {% do inspect_table(schema, table) %}
{% endfor %}

-- This query won't actually run, it's just for inspection logging
SELECT 1 AS dummy
