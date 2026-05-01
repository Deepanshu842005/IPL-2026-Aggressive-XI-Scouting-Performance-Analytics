--Chossing the best Openers 

SELECT 
    "Striker", 
    SUM(runs_on_ball) as pp_runs,
    COUNT(*) as balls_faced,
    ROUND((SUM(runs_on_ball)::numeric / COUNT(*)) * 100, 2) as strike_rate
FROM ipl_full_data
WHERE match_phase = 'Powerplay'
GROUP BY "Striker"
HAVING COUNT(*) >= 100
ORDER BY strike_rate DESC
LIMIT 10;


-- Chossing the Middel Order Batsmans 

SELECT 
    "Striker", 
    SUM(runs_on_ball) as middle_runs,
    COUNT(*) as balls_faced,
    ROUND((SUM(runs_on_ball)::numeric / COUNT(*)) * 100, 2) as strike_rate,
    ROUND(SUM(runs_on_ball)::numeric / COUNT(DISTINCT "Match_ID"), 2) as avg_runs_per_match
FROM ipl_full_data
WHERE match_phase = 'Middle Overs'
GROUP BY "Striker"
HAVING COUNT(*) >= 120
ORDER BY strike_rate DESC
LIMIT 10;


--Chossing the Allrounders 

SELECT 
    bat."Striker" AS player_name,
    COUNT(bat.*) AS balls_faced,
    ROUND((SUM(bat.runs_on_ball)::numeric / COUNT(bat.*)) * 100, 2) AS batting_sr,
    bowl_stats.balls_bowled,
    bowl_stats.economy
FROM ipl_full_data bat
JOIN (
    -- Subquery to calculate bowling stats separately
    SELECT 
        "Bowler", 
        COUNT(*) AS balls_bowled,
        ROUND(SUM(runs_on_ball) / (COUNT(*) / 6.0), 2) AS economy
    FROM ipl_full_data
    GROUP BY "Bowler"
    HAVING COUNT(*) >= 120 -- Min 20 overs bowled
) bowl_stats ON bat."Striker" = bowl_stats."Bowler"
WHERE bat.year >= 2022
GROUP BY bat."Striker", bowl_stats.balls_bowled, bowl_stats.economy
HAVING COUNT(bat.*) >= 100 -- Min 100 balls faced
ORDER BY batting_sr DESC, economy ASC
LIMIT 10;

-- Chossing the Strike Bowlers

SELECT 
    "Bowler", 
    SUM(is_bowler_wicket) as wickets,
    COUNT(*) as balls_bowled,
    ROUND(COUNT(*)::numeric / NULLIF(SUM(is_bowler_wicket), 0), 2) as bowling_strike_rate,
    ROUND(SUM(runs_on_ball) / (COUNT(*) / 6.0), 2) as economy
FROM ipl_full_data
WHERE match_phase = 'Powerplay' 
  AND year >= 2022
GROUP BY "Bowler"
HAVING COUNT(*) >= 120 -- Min 20 overs bowled in Powerplay
ORDER BY bowling_strike_rate ASC
LIMIT 10;

-- Chossing the Spin Duo 

SELECT 
    "Bowler", 
    COUNT(*) / 6 AS overs_bowled,
    SUM(is_bowler_wicket) AS total_wickets,
    ROUND(COUNT(*)::numeric / NULLIF(SUM(is_bowler_wicket), 0), 2) AS bowling_strike_rate,
    ROUND(SUM(runs_on_ball) / (COUNT(*) / 6.0), 2) AS economy_rate
FROM ipl_full_data
WHERE match_phase = 'Middle Overs'
  AND year >= 2022
GROUP BY "Bowler"
HAVING COUNT(*) >= 150 -- Min 25 overs in middle phase
ORDER BY economy_rate ASC, bowling_strike_rate ASC
LIMIT 10;

-- Chossing the Death Bowlers 

SELECT 
    "Bowler", 
    SUM(is_bowler_wicket) as wickets,
    COUNT(*) as balls_bowled,
    ROUND((SUM(runs_on_ball)::numeric / (COUNT(*) / 6.0)), 2) as death_economy,
    ROUND(COUNT(*)::numeric / NULLIF(SUM(is_bowler_wicket), 0), 2) as strike_rate
FROM ipl_full_data
WHERE match_phase = 'Death Overs' 
  AND year >= 2022
GROUP BY "Bowler"
HAVING COUNT(*) >= 120 -- Min 20 overs bowled at the death
ORDER BY death_economy ASC
LIMIT 10;