{{ config(materialized='table') }}

with raw as (

    select
        cast(replace(match_id, '.json', '') as integer) as match_id,
        cast(raw_payload->'info'->'dates'->>0 as date) as match_date,
        
        -- 1. Extract the tiny dictionary object right at the start!
        raw_payload->'info'->'registry'->'people' as player_registry,
        
        raw_payload
    from bronze_raw.raw_matches_json

),

innings_expanded as (

    select
        r.match_id,
        r.match_date,
        
        -- 2. Pass it down
        r.player_registry, 
        
        inning_obj
    from raw r
    cross join lateral jsonb_array_elements(r.raw_payload->'innings') as inning_obj

),

overs_expanded as (

    select
        match_id,
        match_date,
        
        -- 3. Pass it down again
        player_registry, 
        
        inning_obj->>'team' as batting_team,
        over_obj
    from innings_expanded
    cross join lateral jsonb_array_elements(inning_obj->'overs') as over_obj

),

deliveries_expanded as (

    select
        match_id,
        match_date,
        
        -- 4. Pass it down to the final layer
        player_registry, 
        
        batting_team,
        (over_obj->>'over')::int as over_number,
        delivery_obj
    from overs_expanded
    cross join lateral jsonb_array_elements(over_obj->'deliveries') as delivery_obj

)

select
    match_id,
    match_date,
    batting_team,
    over_number,
    
    -- Raw Names (Keep for human readability in Dimensions)
    delivery_obj->>'batter' as batter_name,
    delivery_obj->>'bowler' as bowler_name,
    delivery_obj->>'non_striker' as non_striker_name,

    -- THE MAGIC: We use the dictionary we passed down to fetch the official IDs!
    player_registry->>(delivery_obj->>'batter') as batter_id,
    player_registry->>(delivery_obj->>'bowler') as bowler_id,
    player_registry->>(delivery_obj->>'non_striker') as non_striker_id,
    
    -- The ML Feature Additions
    delivery_obj->'wickets'->0->'fielders'->0->>'name' as fielder_name,
    coalesce(cast(delivery_obj->'extras'->>'wides' as int), 0) as wide_runs,
    coalesce(cast(delivery_obj->'extras'->>'noballs' as int), 0) as noball_runs,

    -- The Standard Metrics
    (delivery_obj->'runs'->>'batter')::int as batter_runs,
    (delivery_obj->'runs'->>'extras')::int as extra_runs,
    (delivery_obj->'runs'->>'total')::int as total_runs,
    case when delivery_obj ? 'wickets' then true else false end as is_wicket

from deliveries_expanded