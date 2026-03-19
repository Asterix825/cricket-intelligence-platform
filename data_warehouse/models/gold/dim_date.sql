{{ config(materialized='table') }}

with date_series as (
    -- This Postgres function magically generates one row per day!
    select generate_series(
        '2008-01-01'::date, -- IPL started in 2008
        '2030-12-31'::date, -- Future-proofing our warehouse
        '1 day'::interval
    )::date as full_date
)

select
    -- Create a 'Smart Integer' key (e.g., 20080418)
    cast(to_char(full_date, 'YYYYMMDD') as integer) as date_key,
    full_date,
    
    -- Extract highly useful attributes for reporting
    cast(extract(year from full_date) as integer) as year,
    cast(extract(month from full_date) as integer) as month_number,
    trim(to_char(full_date, 'Month')) as month_name,
    cast(extract(isodow from full_date) as integer) as day_of_week,
    trim(to_char(full_date, 'Day')) as day_name,
    
    -- Flag the weekends! (ISODOW 6 is Saturday, 7 is Sunday)
    case 
        when extract(isodow from full_date) in (6, 7) then true 
        else false 
    end as is_weekend

from date_series