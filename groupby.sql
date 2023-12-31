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

/*
Write a query that joins tutorial.crunchbase_companies and tutorial.crunchbase_investments_part1 using a FULL JOIN. 
Count up the number of rows that are matched/unmatched as in the example above.
*/
SELECT 
  COUNT(CASE WHEN permalink IS NULL AND investor_permalink IS NOT NULL THEN investor_permalink ELSE NULL END) AS invest_nonmatch,
  COUNT(CASE WHEN permalink IS NOT NULL AND investor_permalink IS NULL THEN permalink ELSE NULL END) AS company_nonmatch,
  COUNT(CASE WHEN permalink IS NOT NULL AND investor_permalink IS NOT NULL THEN investor_permalink ELSE NULL END) AS full_match
FROM tutorial.crunchbase_companies companies
FULL JOIN tutorial.crunchbase_investments_part1 investments
  ON companies.permalink = investments.company_permalink


  /*
 Write a query that shows 3 columns. The first indicates which dataset (part 1 or 2) the data comes from, 
 the second shows company status, and the third is a count of the number of investors.
 
 Hint: you will have to use the tutorial.crunchbase_companies table as well as the investments tables. 
 And you'll want to group by status and dataset.
 */
SELECT 'investments_part1' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

 UNION ALL
 
 SELECT 'investments_part2' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part2 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

/*
 Write a query that appends the two crunchbase_investments datasets above 
 (including duplicate values). Filter the first dataset to only companies with names that start
 with the letter "T", and filter the second to companies with names starting with "M" (both not case-sensitive). 
 Only include the company_permalink, company_name, and investor_name columns.
 */
SELECT
  company_permalink, company_name, investor_name
FROM
  tutorial.crunchbase_investments_part2
WHERE company_name ILIKE 'T%'
UNION
ALL
SELECT
    company_permalink, company_name, investor_name
FROM
  tutorial.crunchbase_investments_part1
WHERE LOWER(company_name) ILIKE 'M%'


/*
Convert the funding_total_usd and founded_at_clean columns in the tutorial.crunchbase_companies_clean_date
table to strings (varchar format) using a different formatting function for each one.
 */
SELECT funding_total_usd::varchar, CAST(founded_at_clean AS varchar)
  FROM tutorial.crunchbase_companies_clean_date

/*
 Write a query that counts the number of companies acquired within 3 years, 5 years, 
 and 10 years of being founded (in 3 separate columns). 
 Include a column for total companies acquired as well. Group by category and limit to only rows with a founding date.
 */
SELECT
category_code,
COUNT(CASE WHEN (NOW() - acquired_at_cleaned::timestamp) < INTERVAL '3 years' THEN '1' ELSE NULL END) AS three_years,
COUNT(CASE WHEN (NOW() - acquired_at_cleaned::timestamp) < INTERVAL '5 years' THEN '1' ELSE NULL END) AS five_years,
COUNT(CASE WHEN (NOW() - acquired_at_cleaned::timestamp) < INTERVAL '10 years' THEN '1' ELSE NULL END) AS ten_years,
COUNT(acquirer_permalink) AS total
FROM
  tutorial.crunchbase_companies_clean_date companies
   JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
    WHERE companies.founded_at_clean IS NOT NULL
    GROUP BY category_code


/*
 Write a query that separates the `location` field into separate fields for latitude and longitude. 
 You can compare your results against the actual `lat` and `lon` fields in the table.
 */
  SELECT location,
       TRIM(leading '(' FROM LEFT(location, POSITION(',' IN location) - 1)) AS lattitude,
       TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) - POSITION(',' IN location) ) ) AS longitude
  FROM tutorial.sf_crime_incidents_2014_01

  /*
Concatenate the lat and lon fields to form a field that is equivalent to the location field.
(Note that the answer will have a different decimal precision.)
 */

  SELECT lat, lon, CONCAT('(', lat, ', ', lon, ')') AS latlon
  FROM tutorial.sf_crime_incidents_2014_01

  /*
Create the same concatenated location field, but using the || syntax instead of CONCAT.
 */

  SELECT lat, lon, CONCAT('(' || lat || ', ' || lon || ')') AS latlon
  FROM tutorial.sf_crime_incidents_2014_01

  /*
Write a query that creates a date column formatted YYYY-MM-DD.
 */

  SELECT date, CONCAT(RIGHT(LEFT(date, 10), 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) AS final_date
  FROM tutorial.sf_crime_incidents_2014_01

  /*
 Write a query that returns the `category` field, 
 but with the first letter capitalized and the rest of the letters in lower-case. */
SELECT
  category,
  CONCAT(
    UPPER(LEFT(category, 1)),
    LOWER(SUBSTR(category, 2, LENGTH(category)))
  )
FROM
  tutorial.sf_crime_incidents_2014_01


/*
 Write a query that creates an accurate timestamp using the date and time columns in tutorial.sf_crime_incidents_2014_01. 
 Include a field that is exactly 1 week later as well. 
 */
SELECT
  CONCAT(
    SUBSTR(date, 7, 4),
    '-',
    SUBSTR(date, 1, 2),
    '-',
    SUBSTR(date, 4, 2),
    ' ',
    time,
    ':00'
  ) :: timestamp AS concat_date,
  CONCAT(
    SUBSTR(date, 7, 4),
    '-',
    SUBSTR(date, 1, 2),
    '-',
    SUBSTR(date, 4, 2),
    ' ',
    time,
    ':00'
  ) :: timestamp + INTERVAL '7DAYS' AS week_date,
  date,
  time
FROM
  tutorial.sf_crime_incidents_2014_01


  /*
Write a query that counts the number of incidents reported by week. Cast the week as a date to get rid of the hours/minutes/seconds.
 */
SELECT 
       DATE_TRUNC('week'   , cleaned_date)::date AS week,
       COUNT(*) AS num_incidents
  FROM tutorial.sf_crime_incidents_cleandate
  GROUP BY week
  ORDER BY 1


  /*
Write a query that shows exactly how long ago each indicent was reported. Assume that the dataset is in Pacific Standard Time (UTC - 8).
 */
  SELECT (NOW() AT TIME ZONE 'PST' - cleaned_date) AS difference, cleaned_date
  FROM tutorial.sf_crime_incidents_cleandate

  /*
Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset,
then wrap it in an outer query that only displays unresolved incidents.
*/

  
  
  SELECT *
  FROM (
    SELECT * 
    FROM tutorial.sf_crime_incidents_2014_01
    WHERE descript = 'WARRANT ARREST'
  ) warrant
  WHERE resolution = 'NONE'

  /*
 Write a query that displays the average number of monthly incidents for each category. 
 Hint: use tutorial.sf_crime_incidents_cleandate to make your life a little easier.
 */
SELECT
  category,
  AVG(incidents)
FROM
  (
    SELECT
      EXTRACT(
        MONTH
        FROM
          cleaned_date
      ) AS MONTH,
      category,
      COUNT(*) AS incidents
    FROM
      tutorial.sf_crime_incidents_cleandate
    GROUP BY
      1,
      2
  ) sub
GROUP BY
  1


  /*
 Write a query that displays all rows from the three categories with the fewest incidents reported.
*/
SELECT *
FROM tutorial.sf_crime_incidents_2014_01 AS one
  JOIN (
  SELECT
 category, COUNT(DISTINCT incidnt_num) AS num_incidents
FROM
  tutorial.sf_crime_incidents_2014_01
GROUP BY 1
ORDER BY 2
LIMIT 3
  ) AS two ON one.category = two.category

/*
 Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012. 
 Create the aggregations in two separate queries, then join them.
 */
SELECT
  COALESCE(acquired_quarter, funded_quarter) AS quarter,
  acquired_companies,
  funded_companies
FROM
  (
    SELECT
      acquired_quarter,
      COUNT(DISTINCT company_permalink) AS acquired_companies
    FROM
      tutorial.crunchbase_acquisitions
    GROUP BY
      1
    ORDER BY
      1
  ) acquired
  FULL JOIN (
    SELECT
      funded_quarter,
      COUNT(DISTINCT company_permalink) AS funded_companies
    FROM
      tutorial.crunchbase_investments
    GROUP BY
      1
    ORDER BY
      1
  ) funded
  ON acquired.acquired_quarter = funded.funded_quarter

  /*
 Write a query that ranks investors from the combined dataset above by the total number of investments they have made.
 */
SELECT
  investor_name, COUNT(DISTINCT company_permalink)
FROM
  (
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part1
    UNION
    ALL
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part2
  ) sub
  GROUP BY 1
  ORDER BY 2 DESC

  /*
Write a query that does the same thing as in the previous problem, except only for companies that are still operating. 
Hint: operating status is in tutorial.crunchbase_companies. */
SELECT
  investments.investor_name, COUNT(DISTINCT investments.company_permalink)
FROM tutorial.crunchbase_companies companies
JOIN 
  (
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part1
    UNION
    ALL
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part2
  ) investments 
  ON companies.permalink = investments.company_permalink
  WHERE companies.status = 'operating'
  GROUP BY 1
  ORDER BY 2 DESC


/*
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal) AS start_terminal_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

Write a query modification of the above example query that shows the duration of each ride
as a percentage of the total time accrued by riders from each start_terminal */
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER (Partition by start_terminal) AS terminal_total, 
       SUM(duration_seconds) OVER (Partition by start_terminal ORDER BY start_time) AS running_total,
      (SUM(duration_seconds) OVER (Partition by start_terminal ORDER BY start_time))/duration_seconds AS start_terminal_percentage
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

 /*
Write a query that shows a running total of the duration of bike rides (similar to the last example),
but grouped by end_terminal, and with ride duration sorted in descending order.*/
SELECT end_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

 /*
 Write a query that shows the 5 longest rides from each starting terminal, ordered by terminal, 
 and longest to shortest rides within each terminal. Limit to rides that occurred before Jan. 8, 2012.
 */
SELECT
  *
FROM
  (
    SELECT
      start_terminal,
      MAX(duration_seconds) OVER (
        PARTITION BY start_terminal
        ORDER BY
          start_terminal
      ) AS max_ride_duration,
      MIN(duration_seconds) OVER (
        PARTITION BY start_terminal
        ORDER BY
          start_terminal
      ) AS min_ride_duration,
      RANK() OVER (
        PARTITION BY start_terminal
        ORDER BY
          duration_seconds
      ) AS rank_ride_time,
      duration_seconds
    FROM
      tutorial.dc_bikeshare_q1_2012
    WHERE
      start_time < '2012-01-08'
  ) sub
WHERE
  sub.rank_ride_time <= 5


  /*
 Write a query that shows only the duration of the trip and the percentile
 into which that duration falls (across the entire dataset—not partitioned by terminal).
 */


SELECT duration_seconds, NTILE(100) OVER (ORDER BY duration_seconds) AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY duration_seconds DESC


/*
Window alias
 */

SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
 
 SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER ntile_window AS quartile,
       NTILE(5) OVER ntile_window AS quintile,
       NTILE(100) OVER ntile_window AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
WINDOW ntile_window AS
         (PARTITION BY start_terminal ORDER BY duration_seconds)
 ORDER BY start_terminal, duration_seconds


 /*
Pivoting
 */
SELECT years.*,
       earthquakes.magnitude,
       CASE year
         WHEN 2000 THEN year_2000
         WHEN 2001 THEN year_2001
         WHEN 2002 THEN year_2002
         WHEN 2003 THEN year_2003
         WHEN 2004 THEN year_2004
         WHEN 2005 THEN year_2005
         WHEN 2006 THEN year_2006
         WHEN 2007 THEN year_2007
         WHEN 2008 THEN year_2008
         WHEN 2009 THEN year_2009
         WHEN 2010 THEN year_2010
         WHEN 2011 THEN year_2011
         WHEN 2012 THEN year_2012
         ELSE NULL END
         AS number_of_earthquakes
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years