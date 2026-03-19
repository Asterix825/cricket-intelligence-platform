{{ config(materialized='table') }}

with batter_sequence as (
    select
        match_key,
        batter_key,
        over_number,
        batter_runs,
        is_wicket,
        
        -- Look at the exact runs scored on the previous 3 balls faced by THIS batter in THIS match
        lag(batter_runs, 1) over(partition by match_key, batter_key order by over_number) as prev_ball_1,
        lag(batter_runs, 2) over(partition by match_key, batter_key order by over_number) as prev_ball_2,
        lag(batter_runs, 3) over(partition by match_key, batter_key order by over_number) as prev_ball_3
        
    from {{ ref('fact_ball_events') }}
),

pressure_flags as (
    select 
        *,
        -- Flag the current ball IF the previous 3 balls were all dots (0 runs)
        case 
            when prev_ball_1 = 0 and prev_ball_2 = 0 and prev_ball_3 = 0 then 1 
            else 0 
        end as is_high_pressure_ball
    from batter_sequence
)

select 
    p.batter_key,
    dp.player_name,
    
    count(*) as total_balls_faced,
    sum(is_high_pressure_ball) as pressure_situations_faced,
    
    -- How did they react to the pressure?
    sum(case when is_high_pressure_ball = 1 and batter_runs >= 4 then 1 else 0 end) as boundaries_under_pressure,
    sum(case when is_high_pressure_ball = 1 and is_wicket = true then 1 else 0 end) as wickets_under_pressure,
    
    -- The Ultimate DBPI Metric: (Boundaries - Wickets) / Pressure Situations
    case 
        when sum(is_high_pressure_ball) > 0 
        then round(
            cast((sum(case when is_high_pressure_ball = 1 and batter_runs >= 4 then 1 else 0 end) - 
                  sum(case when is_high_pressure_ball = 1 and is_wicket = true then 1 else 0 end)) 
            as numeric) / sum(is_high_pressure_ball), 3
        )
        else 0 
    end as dbpi_score

from pressure_flags p
join {{ ref('dim_player') }} dp on p.batter_key = dp.player_key
group by 1, 2