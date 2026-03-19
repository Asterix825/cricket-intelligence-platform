{{ config(materialized='table') }}

with batting_stats as (
    select 
        match_key, 
        date_key, 
        batter_key as player_key,
        sum(batter_runs) as runs_scored, 
        count(*) as balls_faced
    from {{ ref('fact_ball_events') }}
    group by 1, 2, 3
),

bowling_stats as (
    select 
        match_key, 
        date_key, 
        bowler_key as player_key,
        sum(case when is_wicket then 1 else 0 end) as wickets_taken, 
        sum(total_runs) as runs_conceded
    from {{ ref('fact_ball_events') }}
    group by 1, 2, 3
)

select
    coalesce(b.match_key, bw.match_key) as match_key,
    coalesce(b.date_key, bw.date_key) as date_key,
    coalesce(b.player_key, bw.player_key) as player_key,
    coalesce(b.runs_scored, 0) as runs_scored,
    coalesce(b.balls_faced, 0) as balls_faced,
    -- Calculate strike rate safely to avoid division by zero
    case when coalesce(b.balls_faced, 0) > 0 
         then (b.runs_scored * 100.0) / b.balls_faced 
         else 0 
    end as strike_rate,
    coalesce(bw.wickets_taken, 0) as wickets_taken,
    coalesce(bw.runs_conceded, 0) as runs_conceded
from batting_stats b
full outer join bowling_stats bw
    on b.match_key = bw.match_key 
    and b.player_key = bw.player_key