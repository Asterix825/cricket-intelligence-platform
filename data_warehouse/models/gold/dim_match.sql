{{ config(materialized='table') }}

select
    -- We cast to string because the hash function expects text!
    {{ dbt_utils.generate_surrogate_key(['cast(match_id as text)']) }} as match_key,
    
    cast(to_char(match_date, 'YYYYMMDD') as integer) as date_key,
    match_date,
    match_id,
    season,
    city,
    venue,
    match_type,
    team_1,
    team_2,
    winner

from {{ ref('stg_matches') }}