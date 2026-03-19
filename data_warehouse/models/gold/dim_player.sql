-- {{ config(materialized='table') }}

-- with all_players as (
--     select batter as player_name from {{ ref('stg_ball_events') }}
--     union
--     select bowler as player_name from {{ ref('stg_ball_events') }}
-- ),
-- distinct_players as (
--     select distinct player_name 
--     from all_players 
--     where player_name is not null
-- )

-- select
--     {{ dbt_utils.generate_surrogate_key(['lower(trim(player_name))']) }} as player_key,
--     player_name
-- from distinct_players


{{ config(materialized='table') }}

with all_players as (
    select batter_id as player_key, batter_name as player_name 
    from {{ ref('stg_ball_events') }} 
    where batter_id is not null
    
    union
    
    select bowler_id as player_key, bowler_name as player_name 
    from {{ ref('stg_ball_events') }} 
    where bowler_id is not null
    
    union
    
    select non_striker_id as player_key, non_striker_name as player_name 
    from {{ ref('stg_ball_events') }} 
    where non_striker_id is not null
)

select 
    {{ dbt_utils.generate_surrogate_key(["'cricsheet'", 'player_key']) }} as player_key, 
    max(player_name) as player_name
from all_players
group by 1