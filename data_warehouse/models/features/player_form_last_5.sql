{{ config(materialized='table') }}

select
    match_key,
    date_key,
    player_key,
    
    -- Rolling Average Runs (Strictly Preceding)
    coalesce(avg(runs_scored) over (
        partition by player_key
        order by date_key
        rows between 5 preceding and 1 preceding
    ), 0) as avg_runs_last_5_matches,
    
    -- Rolling Average Strike Rate (Strictly Preceding)
    coalesce(avg(strike_rate) over (
        partition by player_key
        order by date_key
        rows between 5 preceding and 1 preceding
    ), 0) as avg_strike_rate_last_5

from {{ ref('player_match_features') }}