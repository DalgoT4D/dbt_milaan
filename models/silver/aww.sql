{{ config(materialized='table', schema='silver') }}

-- Unified AWW (Anganwadi Worker) master table from 8 district/block-specific CSV files.
-- Aggregates all workers across Bahraich blocks into a single table with consistent schema.
-- Rows with blank aww_id are logged to aww_logs table and excluded here.
--
-- Config-driven via the generate_aww_union macro.
-- To add/modify files: update the macro definition in macros/generate_aww_union.sql.

{{ generate_aww_union() }}
