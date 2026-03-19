{{ config(materialized='table') }}

select
    match_key,
    date_key,
    batting_team_key as team_key,
    
    sum(total_runs) as team_total_runs,
    sum(case when is_wicket then 1 else 0 end) as total_wickets_lost,
    
    
    round(cast((sum(total_runs) / (count(*) / 6.0)) as numeric), 2) as team_run_rate

from {{ ref('fact_ball_events') }}
group by 1, 2, 3