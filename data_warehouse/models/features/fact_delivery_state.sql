{{ config(materialized='table') }}

WITH first_innings_summary AS (
    --Calculate the final target set in the 1st innings
    SELECT 
        match_key,
        SUM(total_runs) AS first_innings_total,
        SUM(total_runs) + 1 AS target_score
    FROM {{ ref('fact_ball_events') }}
    WHERE innings = 1
    GROUP BY 1
),

running_state AS (
    --Calculate the state BEFORE the current ball is bowled
    SELECT 
        match_key,
        date_key,
        innings,
        over_number,
        ball_number,
        batting_team_key,
        
        COALESCE(SUM(total_runs) OVER (
            PARTITION BY match_key, innings 
            ORDER BY over_number, ball_number
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS current_score,
        
        COALESCE(SUM(CAST(is_wicket AS INT)) OVER (
            PARTITION BY match_key, innings 
            ORDER BY over_number, ball_number
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS wickets_lost,
        
        ROW_NUMBER() OVER (
            PARTITION BY match_key, innings 
            ORDER BY over_number, ball_number
        ) - 1 AS balls_bowled
        
    FROM {{ ref('fact_ball_events') }}
)

SELECT 
    rs.match_key,
    rs.date_key,
    rs.innings,
    rs.over_number,
    rs.ball_number,
    rs.batting_team_key,
    rs.current_score,
    rs.wickets_lost,
    120 - rs.balls_bowled AS balls_remaining,
    
    fi.target_score,
    
    CASE 
        WHEN rs.innings = 2 THEN fi.target_score - rs.current_score
        ELSE NULL 
    END AS runs_required,
    
    CASE 
        WHEN rs.balls_bowled > 0 THEN (rs.current_score::numeric / rs.balls_bowled) * 6 
        ELSE 0 
    END AS crr,
    
    CASE 
        WHEN rs.innings = 2 AND (120 - rs.balls_bowled) > 0 
        THEN ((fi.target_score - rs.current_score)::numeric / (120 - rs.balls_bowled)) * 6
        ELSE NULL 
    END AS rrr
    
FROM running_state rs
LEFT JOIN first_innings_summary fi ON rs.match_key = fi.match_key
 