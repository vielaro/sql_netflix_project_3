DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT *
FROM netflix


--15 Business Problems


--1. Count the number of Movies vs TV Shows
SELECT
type,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*), 
		RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
) AS t1
WHERE
	ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(string_to_array(country, ',  ')) AS new_country,
	COUNT(*) total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the longest movie

SELECT 
	title,
	duration
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--6. Find content added in the last 5 years
SELECT 
	*,
	TO_DATE(date_added, 'Month DD, YYYY')
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



--7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE 
	director ILIKE  '%Rajiv Chilaka%';   /*adding ILIKE makes sure the query is not case sensitive*/


--8. List all TV shows with more than 5 seasons

SELECT 
	title,
	type,
	SPLIT_PART(duration, ' ', 1) AS season
FROM netflix 
WHERE type = 'TV Show'
AND
SPLIT_PART(duration, ' ', 1)::numeric > 5; 


--9. Count the number of content items in each genre

SELECT 
	UNNEST(string_to_array(listed_in, ', ')) AS new_genre,
	COUNT(*) AS content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2)AS avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1;


--11. List all movies that are documentaries
SELECT 
	title,
	listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';



--12. Find all content without a director

SELECT 
title,
director
FROM netflix
WHERE director IS NULL;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	UNNEST(string_to_array(casts, ',')) AS actors,
	COUNT(*) AS total_movies
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

WITH new_table
AS 
(
SELECT *,
	CASE 
	WHEN 
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'bad_content'
	ELSE 'good_content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;



	
