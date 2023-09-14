SELECT CASE WHEN year IN ('FR', 'SO') THEN 'underclass'
WHEN year IN ('JR', 'SR') THEN 'upperclass'
ELSE NULL END AS class_group, 
SUM(weight) AS combined_player_weight
FROM benn.college_football_players
WHERE state = 'CA'
GROUP BY 1