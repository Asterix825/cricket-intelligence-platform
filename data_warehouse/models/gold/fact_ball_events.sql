{{ config(materialized='table') }}

select
    {{ dbt_utils.generate_surrogate_key(['cast(match_id as text)']) }} as match_key,
    cast(to_char(match_date, 'YYYYMMDD') as integer) as date_key,
    {{ dbt_utils.generate_surrogate_key(['lower(trim(batting_team))']) }} as batting_team_key,
    
    --  The New Perfect Player surrogate Keys 
    {{ dbt_utils.generate_surrogate_key(["'cricsheet'", 'batter_id']) }} as batter_key,
    {{ dbt_utils.generate_surrogate_key(["'cricsheet'", 'bowler_id']) }} as bowler_key,
    {{ dbt_utils.generate_surrogate_key(["'cricsheet'", 'non_striker_id']) }} as non_striker_key,
    
    innings,
    ball_number,
    over_number,

    batter_runs,
    extra_runs,
    total_runs,
    is_wicket,

    fielder_name,
    wide_runs,
    noball_runs

from {{ ref('stg_ball_events') }}