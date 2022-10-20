/************************************************************************************************
Question 1: Get the common commodities between the Top 10 costliest commodities of 2019 and 2020.
************************************************************************************************/
USE commodity_db;

WITH year1_summary AS
(
SELECT 
commodity_id, 
MAX(retail_price) as price
FROM price_details
WHERE YEAR(date)=2019
GROUP BY commodity_id
ORDER BY price DESC
LIMIT 10
),
year2_summary AS
(
SELECT 
commodity_id, 
MAX(retail_price) as price
FROM price_details
WHERE YEAR(date)=2020
GROUP BY commodity_id
ORDER BY price DESC
LIMIT 10
),
common_commodities AS
(
SELECT y1.commodity_id
FROM 
year1_summary AS y1
INNER JOIN
year2_summary AS y2
ON y1.commodity_id=y2.commodity_id
)
SELECT DISTINCT ci.commodity AS common_commodity_list
FROM
common_commodities as cc
JOIN
commodities_info as ci
ON cc.commodity_id=ci.id;


/************************************************************************************************
Question 2: What is the maximum difference between the prices of a commodity at one place vs the other 
for the month of Jun 2020? Which commodity was it for?

************************************************************************************************/
USE commodity_db;

WITH june_prices AS
(
SELECT commodity_id, 
MIN(retail_price) AS Min_price,
MAX(retail_price) AS Max_price
FROM price_details
WHERE date BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY commodity_id
)
SELECT ci.commodity,
Max_price-Min_price AS price_difference
FROM
june_prices as jp
JOIN
commodities_info as ci
ON jp.commodity_id=ci.id
ORDER BY price_difference DESC
LIMIT 1; 



/************************************************************************************************
Question 3: Arrange the commodities in order based on the number of varieties in which they are available, 
with the highest one shown at the top. Which is the 3rd commodity in the list?

************************************************************************************************/
USE commodity_db;

SELECT 
Commodity,
COUNT(DISTINCT Variety) AS Variety_count
FROM 
commodities_info
GROUP BY Commodity
ORDER BY Variety_count DESC;


/************************************************************************************************
Question 4: In the state with the least number of data points available. 
Which commodity has the highest number of data points available?

************************************************************************************************/
USE commodity_db;

WITH raw_data AS
(
SELECT 
pd.id, pd.commodity_id, ri.state
FROM
price_details as pd
LEFT JOIN
region_info as ri
ON pd.region_id = ri.id
),
state_rec_count AS
(
SELECT state, 
COUNT(id) as state_wise_datapoints
FROM raw_data
GROUP BY state
ORDER BY state_wise_datapoints
LIMIT 1
),
commodity_list AS
(
SELECT 
commodity_id,
COUNT(id) AS record_count
FROM 
raw_data
WHERE state IN (SELECT DISTINCT state FROM state_rec_count)
GROUP BY commodity_id
ORDER BY record_count DESC
)
SELECT 
commodity,
SUM(record_count) AS record_count
FROM
commodity_list AS cl
LEFT JOIN
commodities_info AS ci
ON cl.commodity_id = ci.id
GROUP BY commodity
ORDER BY record_count DESC
LIMIT 1;

/*******************************************************************************************************
Question 5: What is the price variation of commodities for each city from Jan 2019 to Dec 2020. 
			Which commodity has seen the highest price variation and in which city?
********************************************************************************************************/
USE commodity_db;

WITH jan_2019_data AS
(
SELECT * 
FROM 
price_details
WHERE date BETWEEN '2019-01-01' AND '2019-01-31'
),
dec_2020_data AS
(
SELECT * 
FROM 
price_details
WHERE date BETWEEN '2020-12-01' AND '2020-12-31'
),
price_variation AS
(
SELECT j.region_id,
j.commodity_id,
j.retail_price AS start_price,
d.retail_price AS end_price,
d.retail_price - j.retail_price AS variation,
ROUND( (d.retail_price - j.retail_price)/j.retail_price*100 ,2) AS variation_percentage
FROM 
jan_2019_data as j
INNER JOIN
dec_2020_data as d
ON j.region_id = d.region_id
AND j.commodity_id=d.commodity_id
ORDER BY variation_percentage DESC
LIMIT 1
)
SELECT  
r.centre as city, 
c.commodity as commodity_name,
start_price,
end_price,
variation,
variation_percentage
FROM 
price_variation as p
JOIN
region_info r
ON p.region_id = r.id
JOIN
commodities_info as c
ON p.commodity_id=c.id;