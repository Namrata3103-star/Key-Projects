USE imdb;


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT COUNT(*) AS total_rows_1 FROM director_mapping;
SELECT COUNT(*) AS total_rows_2 FROM genre;
SELECT COUNT(*) AS total_rows_3 FROM movie;
SELECT COUNT(*) AS total_rows_4 FROM names;
SELECT COUNT(*) AS total_rows_5 FROM ratings;
SELECT COUNT(*) AS total_rows_6 FROM role_mapping;



-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT
SUM(CASE WHEN id is NULL THEN 1 ELSE 0 END) AS id_null,
SUM(CASE WHEN title is NULL THEN 1 ELSE 0 END) AS title_nulls,
SUM(CASE WHEN year is NULL THEN 1 ELSE 0 END) AS year_nulls,
SUM(CASE WHEN date_published is NULL THEN 1 ELSE 0 END) AS date_published_nulls,
SUM(CASE WHEN duration is NULL THEN 1 ELSE 0 END) AS duration_null,
SUM(CASE WHEN country is NULL THEN 1 ELSE 0 END) AS country_null,
SUM(CASE WHEN worlwide_gross_income is NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls,
SUM(CASE WHEN languages is NULL THEN 1 ELSE 0 END) AS languages_nulls,
SUM(CASE WHEN production_company is NULL THEN 1 ELSE 0 END) AS production_company_nulls
FROM movie;



-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
-- Type your code below:

SELECT year,COUNT(id) AS number_of_movies FROM movie 
GROUP BY year ORDER BY year;


SELECT month(date_published) AS month_num,COUNT(id) AS number_of_movies FROM movie
GROUP BY month(date_published) ORDER BY month(date_published) ;

  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT COUNT(id) AS number_of_movies FROM movie 
WHERE (country LIKE '%USA%' OR country LIKE '%India%') AND year=2019;


-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT genre FROM genre;



-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT genre,COUNT(movie_id) AS movie_count FROM genre 
GROUP BY genre ORDER BY COUNT(movie_id) DESC;



-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH movies_count AS
(
SELECT movie_id,COUNT(genre) AS genre_count FROM genre
GROUP BY movie_id HAVING COUNT(genre)=1
)
SELECT COUNT(*) AS total_movies FROM movies_count;


-- Q8.What is the average duration of movies in each genre? 
-- Type your code below:


SELECT genre,ROUND((SUM(duration)/COUNT(duration)),2) AS avg_duration 
FROM movie m INNER JOIN genre g ON m.id=g.movie_id
GROUP BY genre ORDER BY SUM(duration)/COUNT(duration) DESC;


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- Type your code below:

SELECT genre,COUNT(movie_id) AS movie_count, 
DENSE_RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre GROUP BY genre;


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
-- Type your code below:

SELECT MIN(avg_rating) AS min_avg_rating,MAX(avg_rating) AS max_avg_rating,
MIN(total_votes) AS min_total_votes,MAX(total_votes) AS max_total_votes,
MIN(median_rating) AS min_median_rating,MAX(median_rating) AS max_median_rating
FROM ratings;


-- Q11. Which are the top 10 movies based on average rating?
-- Type your code below:


WITH top_movies AS
(
SELECT title,avg_rating,DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
)
SELECT * FROM top_movies 
WHERE movie_rank<=10;





-- Q12. Summarise the ratings table based on the movie counts by median ratings.
-- Type your code below:


SELECT median_rating, COUNT(DISTINCT movie_id) AS movie_count
FROM ratings GROUP BY median_rating ORDER BY COUNT(DISTINCT movie_id) DESC ;



-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
-- Type your code below:

WITH highrated_movies AS
(
SELECT id,production_company, avg_rating
FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
WHERE avg_rating>8
)
SELECT production_company,COUNT(id) AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM highrated_movies 
WHERE production_company IS NOT NULL GROUP BY production_company;


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
-- Type your code below:

WITH US_movies AS 
(
SELECT m.id,genre,year,MONTH(date_published) AS month,country,total_votes 
FROM movie m INNER JOIN genre g ON m.id=g.movie_id
INNER JOIN ratings r ON g.movie_id=r.movie_id 
WHERE total_votes>1000 AND (country LIKE '%USA%') AND MONTH(date_published)=3 AND year=2017
)
SELECT genre,COUNT(id) AS movie_count FROM US_movies
GROUP BY genre ORDER BY COUNT(id) DESC;




-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
-- Type your code below:

SELECT title,avg_rating,genre FROM
movie m INNER JOIN ratings r ON m.id=r.movie_id
INNER JOIN genre g ON r.movie_id=g.movie_id
WHERE avg_rating>8 AND title LIKE 'The%';


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(id) AS movie_count
FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
WHERE MONTH(date_published)=04 AND (year=2018 OR year=2019)
AND median_rating=8;


-- Q17. Do German movies get more votes than Italian movies? 
-- Type your code below:


WITH votes_summary AS
(
SELECT 
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN m.id END) AS german_movie_count,
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN m.id END) AS italian_movie_count,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN r.total_votes END) AS german_movie_votes,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN r.total_votes END) AS italian_movie_votes
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
)
SELECT 
    ROUND(german_movie_votes / german_movie_count, 2) AS german_votes_per_movie,
    ROUND(italian_movie_votes / italian_movie_count, 2) AS italian_votes_per_movie
FROM
    votes_summary;


-- Q18. Which columns in the names table have null values??
-- Type your code below:

SELECT
SUM(CASE WHEN name is NULL THEN 1 ELSE 0 END) AS name_nulls,
SUM(CASE WHEN height is NULL THEN 1 ELSE 0 END) AS height_nulls,
SUM(CASE WHEN date_of_birth is NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
SUM(CASE WHEN known_for_movies is NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- Type your code below:

WITH top_genre_movies AS
(
SELECT genre,movie_id,avg_rating 
FROM genre INNER JOIN ratings USING(movie_id)
WHERE avg_rating>8 
),
top_genres AS
(
SELECT genre,COUNT(movie_id) AS tot_movie
FROM top_genre_movies GROUP BY genre
ORDER BY tot_movie DESC LIMIT 3
)
SELECT name,COUNT(d.movie_id) AS movie_count 
FROM top_genres tg INNER JOIN top_genre_movies t ON t.genre=tg.genre
INNER JOIN director_mapping d ON t.movie_id=d.movie_id
INNER JOIN names n ON n.id=d.name_id
GROUP BY name ORDER BY COUNT(d.movie_id) DESC LIMIT 3;



-- Q20. Who are the top two actors whose movies have a median rating >= 8?
-- Type your code below:

WITH top_movies as 
(
Select movie_id,median_rating,name_id 
from ratings INNER JOIN role_mapping using(movie_id)
WHERE median_rating>=8
)
Select name,COUNT(movie_id) as movie_count
from top_movies t INNER JOIN names n ON t.name_id=n.id
GROUP BY name ORDER BY COUNT(movie_id) DESC limit 2;



-- Q21. Which are the top three production houses based on the number of votes received by their movies?
-- Type your code below:

WITH production_companies AS
(
SELECT production_company,SUM(total_votes) AS vote_count,
DENSE_RANK() OVER (ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM ratings r INNER JOIN movie m ON r.movie_id=m.id
GROUP BY production_company
)
SELECT * FROM production_companies 
WHERE prod_comp_rank<=3;


-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Type your code below:


SELECT name AS actor_name, SUM(total_votes) AS total_votes,COUNT(rm.movie_id) AS movie_count,
ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) AS actor_avg_rating,
DENSE_RANK() OVER(ORDER BY ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) DESC,SUM(total_votes) DESC) AS actor_rank
FROM names n INNER JOIN role_mapping rm ON n.id=rm.name_id
INNER JOIN ratings r ON r.movie_id=rm.movie_id
INNER JOIN movie m ON m.id=r.movie_id
WHERE category='ACTOR' AND country='INDIA'
GROUP BY name HAVING COUNT(rm.movie_id)>=5;

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Type your code below:

SELECT name AS actress_name, SUM(total_votes) AS total_votes,COUNT(rm.movie_id) AS movie_count,
ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) AS actress_avg_rating,
DENSE_RANK() OVER(ORDER BY ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) DESC,SUM(total_votes) DESC) AS actress_rank
FROM names n INNER JOIN role_mapping rm ON n.id=rm.name_id
INNER JOIN ratings r ON r.movie_id=rm.movie_id
INNER JOIN movie m ON m.id=r.movie_id
WHERE category='ACTRESS' AND country='INDIA' AND languages LIKE '%HINDI%'
GROUP BY name HAVING COUNT(rm.movie_id)>=3;



/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT movie_id, avg_rating,
CASE
WHEN avg_rating>8 THEN 'Superhit movies'
WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
ELSE 'Flop movies'
END AS Movie_type
FROM genre INNER JOIN ratings USING(movie_id)
WHERE genre='Thriller';
 



-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- Type your code below:

WITH genre_duration AS
(
SELECT genre,ROUND(SUM(duration)/COUNT(duration),1) AS avg_duration
FROM genre g INNER JOIN movie m ON g.movie_id=m.id
GROUP BY genre ORDER BY (SUM(duration)/COUNT(duration)) DESC
)
SELECT genre,avg_duration,
SUM(avg_duration) OVER(ROWS UNBOUNDED PRECEDING) AS running_total_duration,
ROUND(AVG(avg_duration) OVER(ROWS UNBOUNDED PRECEDING),2) AS moving_avg_duration
FROM genre_duration;


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- Type your code below:



WITH top_genre AS
(
SELECT genre FROM genre 
GROUP BY genre ORDER BY COUNT(movie_id) DESC LIMIT 3
),
top_genre_movies AS
(
SELECT genre,movie_id
FROM top_genre INNER JOIN genre using(genre)
),
high_gross_movie AS
(
SELECT genre,year,title AS movie_name, 
CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worldwide_gross_income,
DENSE_RANK() OVER( PARTITION BY year ORDER  BY  CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) DESC)  AS movie_rank
FROM top_genre_movies tg INNER JOIN movie m ON tg.movie_id=m.id
)
SELECT * FROM high_gross_movie 
WHERE movie_rank<=5;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
-- Type your code below:

WITH multilingual_movies AS
(
SELECT production_company,id,languages,median_rating 
FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
WHERE languages LIKE '%,%' AND median_rating>=8
)
SELECT production_company,COUNT(m.id) AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(m.id) DESC) AS prod_comp_rank
FROM multilingual_movies m INNER JOIN ratings r ON m.id=r.movie_id
WHERE production_company IS NOT NULL 
GROUP BY production_company ORDER BY COUNT(m.id) DESC LIMIT 2;



-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
-- Type your code below:

WITH hit_movies AS
(
SELECT genre,movie_id,avg_rating,total_votes
FROM ratings INNER JOIN genre USING(movie_id)
WHERE avg_rating>8 AND genre='Drama'
)
Select * FROM
(
SELECT name as actress_name,SUM(total_votes) AS sum_votes,COUNT(rm.movie_id) AS movie_count,
ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) AS actress_avg_rating,
DENSE_RANK() OVER(ORDER BY COUNT(rm.movie_id) DESC,(ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2)) DESC,SUM(total_votes) DESC) AS actress_rank
FROM hit_movies h INNER JOIN role_mapping rm ON h.movie_id=rm.movie_id
INNER JOIN names n ON rm.name_id=n.id
WHERE category='ACTRESS' GROUP BY name
) top_actresses
WHERE actress_rank<=3;




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
-*/
-- Type you code below:

WITH top_directors AS
(
SELECT n.id AS director_id,name as director_name,COUNT(d.movie_id) AS number_of_movies,
SUM(total_votes) AS sum_votes,MIN(avg_rating) AS min_rating,MAX(avg_rating) AS max_rating,
SUM(duration) AS total_duration,ROUND(SUM(total_votes*avg_rating)/SUM(total_votes),2) AS director_avg_rating
FROM names n INNER JOIN director_mapping d ON n.id=d.name_id
INNER JOIN movie m ON d.movie_id=m.id
INNER JOIN ratings r ON r.movie_id=m.id
GROUP BY name ORDER BY COUNT(d.movie_id) DESC
),
movie_release_gap AS
(
SELECT name,n.id,date_published,LEAD(date_published,1) OVER(PARTITION BY name ORDER BY date_published) AS next_movie
FROM names n INNER JOIN director_mapping d ON n.id=d.name_id 
INNER JOIN movie m ON m.id=d.movie_id
)
SELECT director_id,director_name,number_of_movies,
ROUND(SUM(DATEDIFF(next_movie,date_published))/COUNT(DATEDIFF(next_movie,date_published)),0) AS avg_inter_movie_days,
director_avg_rating, sum_votes,min_rating,max_rating,total_duration
FROM top_directors td INNER JOIN movie_release_gap mrg ON td.director_name=mrg.name
GROUP BY name ORDER BY number_of_movies DESC,director_avg_rating DESC,
ROUND(SUM(DATEDIFF(next_movie,date_published))/COUNT(DATEDIFF(next_movie,date_published)),0) DESC LIMIT 9;




