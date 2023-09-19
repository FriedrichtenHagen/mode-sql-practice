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

/*
Write a query that displays player names, school names and conferences for schools
in the "FBS (Division I-A Teams)" division.
*/

SELECT player_name, players.school_name, conference
FROM benn.college_football_players AS players
JOIN benn.college_football_teams AS teams ON players.school_name = teams.school_name 
WHERE teams.division = 'FBS (Division I-A Teams)'

/*
Write a query that performs an inner join between the tutorial.crunchbase_acquisitions table and the tutorial.crunchbase_companies table,
but instead of listing individual rows, count the number of non-null rows in each table.
*/
SELECT COUNT(companies.permalink) AS companies_rowcount,
       COUNT(acquisitions.company_permalink) AS acquisitions_rowcount
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink


    /*
Count the number of unique companies (don't double-count companies) and unique acquired companies by state.
Do not include results for which there is no state data, 
and order by the number of acquired companies from highest to lowest.
tutorial.crunchbase_acquisitions acquisitions

COUNT UNIQUE permalink AS num_comps, COUNT UNIQUE company_permalink AS num_aq_comps,

*/
SELECT permalink, COUNT UNIQUE permalink AS num_comps, COUNT UNIQUE company_permalink AS num_aq_comps,
  FROM tutorial.crunchbase_companies companies
   LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
WHERE state_code IS NOT NULL
GROUP BY permalink


SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
   AND acquisitions.company_permalink != '/company/1000memories'
 ORDER BY 1

 /*
Write a query that shows a company's name, "status" (found in the Companies table), 
and the number of unique investors in that company. 
Order by the number of investors from most to fewest. Limit to only companies in the state of New York.
*/

SELECT companies.name AS company_name,
       companies.status,
       COUNT(DISTINCT investments.investor_name) AS unqiue_investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments investments
    ON companies.permalink = investments.company_permalink
 WHERE companies.state_code = 'NY'
 GROUP BY 1,2
 ORDER BY 3 DESC

 /*
Write a query that lists investors based on the number of companies in which they are invested. 
Include a row for companies with no investor, and order from most companies to least.
*/
SELECT investor_name, COUNT(DISTINCT company_name) AS num_invested_companies
FROM tutorial.crunchbase_investments
GROUP BY investor_name
ORDER BY num_invested_companies DESC

