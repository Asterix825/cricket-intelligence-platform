{{ config(materialized='table') }}

with raw as (

    select 
        cast(replace(match_id, '.json', '') as integer) as match_id,
        raw_payload
    from bronze_raw.raw_matches_json

),

parsed as (

    select
        match_id, -- Now we just select the clean ID!
        cast(raw_payload->'info'->'dates'->>0 as date) as match_date,
        raw_payload->'info'->>'city' as city,
        raw_payload->'info'->>'venue' as venue,
        raw_payload->'info'->>'gender' as gender,
        raw_payload->'info'->>'match_type' as match_type,
        raw_payload->'info'->>'season' as season,
        raw_payload->'info'->'teams'->>0 as team_1,
        raw_payload->'info'->'teams'->>1 as team_2,
        raw_payload->'info'->'outcome'->>'winner' as winner
    from raw

)

select *
from parsed