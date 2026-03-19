{{ config(materialized='table') }}

with phase_flags as (
    select 
        batter_key,
        batter_runs,
        is_wicket,
        -- Cricsheet overs are 0-indexed (0 to 19)
        case 
            when over_number between 0 and 5 then '1_Powerplay'
            when over_number between 6 and 14 then '2_Middle_Overs'
            when over_number between 15 and 19 then '3_Death_Overs'
        end as match_phase
    from {{ ref('fact_ball_events') }}
),

global_phase_stats as (
    -- Calculate the baseline average for every phase across IPL history
    select 
        match_phase,
        count(*) as global_balls,
        sum(batter_runs) as global_runs,
        round((sum(batter_runs)::numeric / count(*)) * 100, 2) as global_strike_rate
    from phase_flags
    group by 1
),

player_phase_stats as (
    -- Calculate individual player stats per phase
    select 
        batter_key,
        match_phase,
        count(*) as balls_faced,
        sum(batter_runs) as total_runs
    from phase_flags
    group by 1, 2
)

select 
    p.batter_key,
    dp.player_name,
    p.match_phase,
    p.balls_faced,
    p.total_runs,
    
    -- Standard Player Strike Rate
    case when p.balls_faced > 0 
         then round((p.total_runs::numeric / p.balls_faced) * 100, 2) 
         else 0 
    end as player_strike_rate,
    
    g.global_strike_rate,
    
    -- THE TRUE STRIKE RATE (Player SR minus Global SR)
    case when p.balls_faced > 0 
         then round(((p.total_runs::numeric / p.balls_faced) * 100) - g.global_strike_rate, 2) 
         else 0 
    end as true_strike_rate_value

from player_phase_stats p
join global_phase_stats g on p.match_phase = g.match_phase
join {{ ref('dim_player') }} dp on p.batter_key = dp.player_key
where p.balls_faced > 50 -- Filter out players with tiny sample sizes
order by dp.player_name, p.match_phase