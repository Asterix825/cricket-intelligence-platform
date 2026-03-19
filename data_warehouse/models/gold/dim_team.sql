{{ config(materialized='table') }}

with all_teams as (
    select team_1 as team_name from {{ ref('stg_matches') }}
    union
    select team_2 as team_name from {{ ref('stg_matches') }}
    union
    select batting_team as team_name from {{ ref('stg_ball_events') }}
),
distinct_teams as (
    select distinct team_name 
    from all_teams 
    where team_name is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['lower(trim(team_name))']) }} as team_key,
    team_name
from distinct_teams