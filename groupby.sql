/* Write a query that shows the number of players at schools with names that start with A through M, and the number at schools with names starting with N - Z. */
    /*Version 1*/
    SELECT 
    COUNT(CASE WHEN school_name < 'n' THEN 1 
    ELSE NULL END) AS starts_with_r,
    COUNT(CASE WHEN school_name >= 'n' THEN 1 
    ELSE NULL END) AS starts_with_c
    FROM benn.college_football_players
    /*Version 2*/
    SELECT 
    CASE WHEN school_name < 'n' THEN 'a_m'
            WHEN school_name >= 'n' THEN 'n_z'
    END AS alphabetical_grouping,
    COUNT(1) AS num_students
    FROM benn.college_football_players
    GROUP BY 1


/*
Write a query that separately counts the number of unique values in the month column and the number of unique values in the `year` column.
*/

SELECT 
       COUNT(DISTINCT month) AS months_count, 
       COUNT(DISTINCT year) AS years_count
  FROM tutorial.aapl_historical_stock_price

/*
Write a query that selects the school name, player name, position, and weight for every player in Georgia, ordered by weight (heaviest to lightest). 
Be sure to make an alias for the table, and to reference all column names in relation to the alias.
*/

SELECT players.full_school_name, players.player_name, players.position, players.weight
FROM benn.college_football_players AS players
JOIN benn.college_football_teams AS teams
    ON teams.school_name = players.school_name
WHERE state = 'GA'
ORDER BY weight DESC