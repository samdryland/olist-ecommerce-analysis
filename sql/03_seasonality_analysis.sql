-- seasonal buying trends, will be looking at seasonal trends in 2017 -- 
-- only analysed 2017 because this is the only complete year in the dataset making it the most
-- valuable in analysing seasonal  trends --



	WITH quarter AS (
SELECT  -- query shows total item sales by quarter as a percentage of total sales in 2017-- 
count(case when order_purchase_timestamp >= '2017-01-01' 
AND order_purchase_timestamp < '2017-04-01'
THEN 1 END) AS q1_,
count(case when order_purchase_timestamp >= '2017-04-01' 
AND order_purchase_timestamp < '2017-07-01'
THEN 1 END) AS q2_,
count(case when order_purchase_timestamp >= '2017-07-01' 
AND order_purchase_timestamp < '2017-10-01'
THEN 1 END) AS q3_,
count(case when order_purchase_timestamp >= '2017-10-01' 
AND order_purchase_timestamp < '2018-01-01'
THEN 1 END) AS q4_
FROM order_items oi
join orders o ON o.order_id=oi.order_id
)

SELECT ROUND((q1_ *1.0)/(q1_ + q2_ + q3_ + q4_)*100, 2) AS q1,
  ROUND((q2_ *1.0)/(q1_ + q2_ + q3_ + q4_)*100, 2) AS q2,
   ROUND((q3_ *1.0)/(q1_ + q2_ + q3_ + q4_)*100, 2)AS q3,
    ROUND((q4_ *1.0)/(q1_ + q2_ + q3_ + q4_)*100, 2) AS q4
	FROM quarter

	-- proportion of total Olist sales by quarter:
	-- Q1 - 11.6%
	-- Q2 - 20.5%
	-- Q3 - 28.0%
	-- Q4 - 39.9%


-- below code shows quarterly analysis of top 20 product categories as a percentage of the categories total sales in 2017--

 WITH quarter AS (
SELECT product_category_name_english,  
count(case when order_purchase_timestamp >= '2017-01-01' 
AND order_purchase_timestamp < '2017-04-01'
THEN 1 END) AS q1,
count(case when order_purchase_timestamp >= '2017-04-01' 
AND order_purchase_timestamp < '2017-07-01'
THEN 1 END) AS q2,
count(case when order_purchase_timestamp >= '2017-07-01' 
AND order_purchase_timestamp < '2017-10-01'
THEN 1 END) AS q3,
count(case when order_purchase_timestamp >= '2017-10-01' 
AND order_purchase_timestamp < '2018-01-01'
THEN 1 END) AS q4
FROM order_items oi
JOIN orders o ON o.order_id=oi.order_id
JOIN products p on p.product_id=oi.product_id
JOIN category_translation ct on ct.product_category_name=p.product_category_name
WHERE product_category_name_english IN (
    'bed_bath_table',
    'health_beauty',
    'sports_leisure',
    'furniture_decor',
    'computers_accessories',
    'housewares',
    'watches_gifts',
    'telephony',
    'garden_tools',
    'auto',
    'toys',
    'cool_stuff',
    'perfumery',
    'baby',
    'electronics',
    'stationery',
    'fashion_bags_accessories',
    'pet_shop',
    'office_furniture',
    'consoles_games'
)
group  by product_category_name_english
order by q4 DESC
)
 

 SELECT product_category_name_english as category, 
 ROUND((q1 *1.0)/(q1 + q2 + q3 + q4)*100, 2) AS q1_perc,
 ROUND( (q2 *1.0)/(q1 + q2 + q3 + q4)*100, 2) AS q2_perc,
   ROUND((q3 *1.0)/(q1 + q2 + q3 + q4)*100, 2) AS q3_perc,
    ROUnd((q4 *1.0)/(q1 + q2 + q3 + q4)*100, 2) AS q4_perc
	FROM quarter


-- below shows the monthly sales percentages of product categories which differ from the overall Olist company performance most significantly -- 


WITH mon AS (
SELECT product_category_name_english as cat,
COUNT(case when order_purchase_timestamp >= '2017-01-01'
 AND order_purchase_timestamp < '2017-02-01'then 1 END) AS jan,
 COUNT(case when order_purchase_timestamp >= '2017-02-01'
 AND order_purchase_timestamp < '2017-03-01' then 1 END) AS feb,
 COUNT(case when order_purchase_timestamp >= '2017-03-01'
 AND order_purchase_timestamp < '2017-04-01' then 1 END) AS mar,
 COUNT(case when order_purchase_timestamp >= '2017-04-01'
 AND order_purchase_timestamp < '2017-05-01' then 1 END) AS apr,
 COUNT(case when order_purchase_timestamp >= '2017-05-01'
 AND order_purchase_timestamp < '2017-06-01' then 1 END) AS may,
 COUNT(case when order_purchase_timestamp >= '2017-06-01'
 AND order_purchase_timestamp < '2017-07-01' then 1 END) AS jun,
 COUNT(case when order_purchase_timestamp >= '2017-07-01'
 AND order_purchase_timestamp < '2017-08-01' then 1 END) AS jul,
 COUNT(case when order_purchase_timestamp >= '2017-08-01'
 AND order_purchase_timestamp < '2017-09-01' then 1 END) AS aug,
 COUNT(case when order_purchase_timestamp >= '2017-09-01'
 AND order_purchase_timestamp < '2017-10-01' then 1 END) AS sep,
 COUNT(case when order_purchase_timestamp >= '2017-10-01'
 AND order_purchase_timestamp < '2017-11-01' then 1 END) AS oct,
 COUNT(case when order_purchase_timestamp >= '2017-11-01'
 AND order_purchase_timestamp < '2017-12-01' then 1 END) AS nov,
 COUNT(case when order_purchase_timestamp >= '2017-12-01'
 AND order_purchase_timestamp < '2018-01-01' then 1 END) AS dec
 FROM order_items oi
 JOIN orders o ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 WHERE product_category_name_english IN ('stationery', 'toys', 'garden_tools', 'watches_gifts', 'housewares', 'consoles_games', 'office_furniture', 'electronics')
 Group by product_category_name_english
 )
 
 
 SELECT cat,  jan*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as jp,
 (feb*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec))*100 as fp,
 mar*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as marp,
 apr*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as aprp,
 may*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as mayp,
 jun*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as junp,
 jul*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as julp,
 aug*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as augp,
 sep*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as sepp,
 oct*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as octp,
 nov*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as novp,
 dec*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as decp
 from mon

-- below shows the monthyl sales percentages of Olists overall company --

-- below shows the monthly sales percentage of those singled out categories -- code is correct but doesnt read well in tableau 


WITH mon AS (
SELECT product_category_name_english as cat,
COUNT(case when order_purchase_timestamp >= '2017-01-01'
 AND order_purchase_timestamp < '2017-02-01'then 1 END) AS jan,
 COUNT(case when order_purchase_timestamp >= '2017-02-01'
 AND order_purchase_timestamp < '2017-03-01' then 1 END) AS feb,
 COUNT(case when order_purchase_timestamp >= '2017-03-01'
 AND order_purchase_timestamp < '2017-04-01' then 1 END) AS mar,
 COUNT(case when order_purchase_timestamp >= '2017-04-01'
 AND order_purchase_timestamp < '2017-05-01' then 1 END) AS apr,
 COUNT(case when order_purchase_timestamp >= '2017-05-01'
 AND order_purchase_timestamp < '2017-06-01' then 1 END) AS may,
 COUNT(case when order_purchase_timestamp >= '2017-06-01'
 AND order_purchase_timestamp < '2017-07-01' then 1 END) AS jun,
 COUNT(case when order_purchase_timestamp >= '2017-07-01'
 AND order_purchase_timestamp < '2017-08-01' then 1 END) AS jul,
 COUNT(case when order_purchase_timestamp >= '2017-08-01'
 AND order_purchase_timestamp < '2017-09-01' then 1 END) AS aug,
 COUNT(case when order_purchase_timestamp >= '2017-09-01'
 AND order_purchase_timestamp < '2017-10-01' then 1 END) AS sep,
 COUNT(case when order_purchase_timestamp >= '2017-10-01'
 AND order_purchase_timestamp < '2017-11-01' then 1 END) AS oct,
 COUNT(case when order_purchase_timestamp >= '2017-11-01'
 AND order_purchase_timestamp < '2017-12-01' then 1 END) AS nov,
 COUNT(case when order_purchase_timestamp >= '2017-12-01'
 AND order_purchase_timestamp < '2018-01-01' then 1 END) AS dec
 FROM order_items oi
 JOIN orders o ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 WHERE product_category_name_english IN ('stationery', 'toys', 'garden_tools', 'watches_gifts', 'housewares', 'consoles_games', 'office_furniture', 'electronics')
 Group by product_category_name_english
 )
 
 
 SELECT cat,  jan*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as jp,
 (feb*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec))*100 as fp,
 mar*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as marp,
 apr*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as aprp,
 may*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as mayp,
 jun*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as junp,
 jul*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as julp,
 aug*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as augp,
 sep*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as sepp,
 oct*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec) *100 as octp,
 nov*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as novp,
 dec*1.0/(jan+feb+mar+apr+may+jun+jul+aug+oct+nov+dec)*100 as decp
 from mon



 -- console games investigation to see if high revenue months were driven by specific product/game release or other events possibly black friday--
 
 SELECT count(*)
 from products p 
 join category_translation ct ON ct.product_category_name=p.product_category_name
 where product_category_name_english = 'consoles_games'
 
 -- 317 different consoles games -- 
 
 -- below code is to identify if specific console games are responsible for a large proportion of monthly sales
 
 select p.product_id, COUNT(case when o.order_purchase_timestamp >= '2017-01-01'
 AND o.order_purchase_timestamp < '2017-02-01'then 1 END) AS jan,
 COUNT(case when o.order_purchase_timestamp >= '2017-02-01'
 AND o.order_purchase_timestamp < '2017-03-01' then 1 END) AS feb,
 COUNT(case when o.order_purchase_timestamp >= '2017-03-01'
 AND o.order_purchase_timestamp < '2017-04-01' then 1 END) AS mar,
 COUNT(case when o.order_purchase_timestamp >= '2017-04-01'
 AND o.order_purchase_timestamp < '2017-05-01' then 1 END) AS apr,
 COUNT(case when o.order_purchase_timestamp >= '2017-05-01'
 AND o.order_purchase_timestamp < '2017-06-01' then 1 END) AS may,
 COUNT(case when o.order_purchase_timestamp >= '2017-06-01'
 AND o.order_purchase_timestamp < '2017-07-01' then 1 END) AS jun,
 COUNT(case when o.order_purchase_timestamp >= '2017-07-01'
 AND o.order_purchase_timestamp < '2017-08-01' then 1 END) AS jul,
 COUNT(case when o.order_purchase_timestamp >= '2017-08-01'
 AND o.order_purchase_timestamp < '2017-09-01' then 1 END) AS aug,
 COUNT(case when o.order_purchase_timestamp >= '2017-09-01'
 AND o.order_purchase_timestamp < '2017-10-01' then 1 END) AS sep,
 COUNT(case when order_purchase_timestamp >= '2017-10-01'
 AND o.order_purchase_timestamp < '2017-11-01' then 1 END) AS oct,
 COUNT(case when o.order_purchase_timestamp >= '2017-11-01'
 AND o.order_purchase_timestamp < '2017-12-01' then 1 END) AS nov,
 COUNT(case when o.order_purchase_timestamp >= '2017-12-01'
 AND o.order_purchase_timestamp < '2018-01-01' then 1 END) AS dec
 FROM order_items oi
 JOIN orders o ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 where ct.product_category_name_english = 'consoles_games'
 group by p.product_id
 order by nov DESC
 
 -- below code is to identify the top performing console games in 2017 -- 
 
  select p.product_id, COUNT(*)
 FROM order_items oi
 JOIN orders o ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 where ct.product_category_name_english = 'consoles_games'
 and o.order_purchase_timestamp >= '2017-01-01'
 AND o.order_purchase_timestamp < '2018-01-01' 
 group by p.product_id
 order by count(*) Desc



-- below is to compare the contribution of the 2 best selling games in 2017 to the rest of the games -- 

WITH monthly_sales AS (
    SELECT
        CASE
            WHEN p.product_id = '0aabfb375647d9738ad0f7b4ea3653b1'
                THEN 'Top Game 1'
            WHEN p.product_id = '6c3effec7c8ddba466d4f03f982c7aa3'
                THEN 'Top Game 2'
            ELSE 'All Other Games'
        END AS game_group,

        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        COUNT(*) AS sales

    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    JOIN category_translation ct
        ON ct.product_category_name = p.product_category_name

    WHERE ct.product_category_name_english = 'consoles_games'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-01-01'

    GROUP BY
        game_group,
        strftime('%Y-%m', o.order_purchase_timestamp)
)

SELECT
    game_group,
    month,
    sales
FROM monthly_sales
ORDER BY
    month,
    game_group;


-- below compares the top 2 best selling games against the rest of the games as a whole in terms of percentage 
 -- all games sold in 2017 -- 
 
 WITH sold AS (
    SELECT
        p.product_id AS game,
        COUNT(*) AS sales
    FROM order_items oi
    JOIN products p
        ON p.product_id = oi.product_id
    JOIN category_translation ct
        ON ct.product_category_name = p.product_category_name
    JOIN orders o
        ON o.order_id = oi.order_id
    WHERE ct.product_category_name_english = 'consoles_games'
        AND o.order_purchase_timestamp >= '2017-01-01'
        AND o.order_purchase_timestamp < '2018-01-01'
    GROUP BY p.product_id
),

ranked AS (
    SELECT
        game,
        sales,
        ROW_NUMBER() OVER (ORDER BY sales DESC) AS game_rank
    FROM sold
),

grouped_sales AS (
    SELECT
        CASE
            WHEN game_rank = 1 THEN 'Best Selling Game 1'
            WHEN game_rank = 2 THEN 'Best Selling Game 2'
            ELSE 'All Other Games'
        END AS game_group,
        SUM(sales) AS sales
    FROM ranked
    GROUP BY
        CASE
            WHEN game_rank = 1 THEN 'Best Selling Game 1'
            WHEN game_rank = 2 THEN 'Best Selling Game 2'
            ELSE 'All Other Games'
        END
)

SELECT
    game_group,
    sales,
    ROUND(sales * 100.0 / SUM(sales) OVER (), 2) AS percentage_total_sales
FROM grouped_sales
ORDER BY sales DESC;




  -- product specific sales by month for office furniture -- 
  
  -- below shows the different product IDs sold in each month of 2017 to see if one specific product drove the spike
  -- in sales in july, there was no specific product that caused the spike
  
  select p.product_id, COUNT(case when o.order_purchase_timestamp >= '2017-01-01'
 AND o.order_purchase_timestamp < '2017-02-01'then 1 END) AS jan,
 COUNT(case when o.order_purchase_timestamp >= '2017-02-01'
 AND o.order_purchase_timestamp < '2017-03-01' then 1 END) AS feb,
 COUNT(case when o.order_purchase_timestamp >= '2017-03-01'
 AND o.order_purchase_timestamp < '2017-04-01' then 1 END) AS mar,
 COUNT(case when o.order_purchase_timestamp >= '2017-04-01'
 AND o.order_purchase_timestamp < '2017-05-01' then 1 END) AS apr,
 COUNT(case when o.order_purchase_timestamp >= '2017-05-01'
 AND o.order_purchase_timestamp < '2017-06-01' then 1 END) AS may,
 COUNT(case when o.order_purchase_timestamp >= '2017-06-01'
 AND o.order_purchase_timestamp < '2017-07-01' then 1 END) AS jun,
 COUNT(case when o.order_purchase_timestamp >= '2017-07-01'
 AND o.order_purchase_timestamp < '2017-08-01' then 1 END) AS jul,
 COUNT(case when o.order_purchase_timestamp >= '2017-08-01'
 AND o.order_purchase_timestamp < '2017-09-01' then 1 END) AS aug,
 COUNT(case when o.order_purchase_timestamp >= '2017-09-01'
 AND o.order_purchase_timestamp < '2017-10-01' then 1 END) AS sep,
 COUNT(case when order_purchase_timestamp >= '2017-10-01'
 AND o.order_purchase_timestamp < '2017-11-01' then 1 END) AS oct,
 COUNT(case when o.order_purchase_timestamp >= '2017-11-01'
 AND o.order_purchase_timestamp < '2017-12-01' then 1 END) AS nov,
 COUNT(case when o.order_purchase_timestamp >= '2017-12-01'
 AND o.order_purchase_timestamp < '2018-01-01' then 1 END) AS dec
 FROM order_items oi
 JOIN orders o ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 where ct.product_category_name_english = 'office_furniture'
 group by p.product_id
 order by jul DESC



 -- below shows the number of items within each orders in each month of 2017 to see if one extremely large order caused the spike in sales in july
 -- it did not 

 select o.order_id, COUNT(case when o.order_purchase_timestamp >= '2017-01-01'
 AND o.order_purchase_timestamp < '2017-02-01'then 1 END) AS jan,
 COUNT(case when o.order_purchase_timestamp >= '2017-02-01'
 AND o.order_purchase_timestamp < '2017-03-01' then 1 END) AS feb,
 COUNT(case when o.order_purchase_timestamp >= '2017-03-01'
 AND o.order_purchase_timestamp < '2017-04-01' then 1 END) AS mar,
 COUNT(case when o.order_purchase_timestamp >= '2017-04-01'
 AND o.order_purchase_timestamp < '2017-05-01' then 1 END) AS apr,
 COUNT(case when o.order_purchase_timestamp >= '2017-05-01'
 AND o.order_purchase_timestamp < '2017-06-01' then 1 END) AS may,
 COUNT(case when o.order_purchase_timestamp >= '2017-06-01'
 AND o.order_purchase_timestamp < '2017-07-01' then 1 END) AS jun,
 COUNT(case when o.order_purchase_timestamp >= '2017-07-01'
 AND o.order_purchase_timestamp < '2017-08-01' then 1 END) AS jul,
 COUNT(case when o.order_purchase_timestamp >= '2017-08-01'
 AND o.order_purchase_timestamp < '2017-09-01' then 1 END) AS aug,
 COUNT(case when o.order_purchase_timestamp >= '2017-09-01'
 AND o.order_purchase_timestamp < '2017-10-01' then 1 END) AS sep,
 COUNT(case when order_purchase_timestamp >= '2017-10-01'
 AND o.order_purchase_timestamp < '2017-11-01' then 1 END) AS oct,
 COUNT(case when o.order_purchase_timestamp >= '2017-11-01'
 AND o.order_purchase_timestamp < '2017-12-01' then 1 END) AS nov,
 COUNT(case when o.order_purchase_timestamp >= '2017-12-01'
 AND o.order_purchase_timestamp < '2018-01-01' then 1 END) AS dec
 FROM orders o
 JOIN order_items oi ON oi.order_id=o.order_id
 JOIN products p ON p.product_id=oi.product_id
 JOIN category_translation ct ON ct.product_category_name=p.product_category_name
 JOIN customers c ON o.customer_id=c.customer_id
 where ct.product_category_name_english = 'office_furniture'
 group by o.order_id
 order by jul DESC

 -- below shows the amount of unique customers each month in 2017 in the category of office furniture--

 
SELECT 
    STRFTIME('%m', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
	 JOIN category_translation ct 
	 ON ct.product_category_name=p.product_category_name
WHERE ct.product_category_name_english = 'office_furniture'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-01-01'
GROUP BY month
ORDER BY month

-- July saw a substantial increase in office furniture sales, with the number of
-- unique customers rising from 45 in June to 96 in July before falling back to 46
-- in August.
-- The increase was not driven by one specific product, with sales distributed
-- across a broad range of office furniture products.
-- This suggests the July spike reflected broader category-level demand rather
-- than a single high-performing product or a small number of customers placing
-- unusually large orders.
	
