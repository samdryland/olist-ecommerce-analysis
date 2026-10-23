-- average review score across whole company --

select AVG(review_score)
from  order_reviews

--  here i am looking at the average reviews in each category and also showing where they rank 
-- in terms of revenue for Olist this will identify if any product categories which have bad reviews still generate-
-- large amounts of revenue, if this is fixed they could explode and drive larger sales.
select product_category_name_english,
ROUND(AVG(review_score), 2) as avg_review, 
count(oi.product_id) as sales,
sum(price) as product_rev,
dense_rank () OVER (order by sum(price)DESC) as rev_rank
from order_reviews ore
JOIN order_items oi ON oi.order_id=ore.order_id
JOIN products p ON p.product_id=oi.product_id
JOIN category_translation ct ON ct.product_category_name=p.product_category_name
group by product_category_name_english
order by avg_review


-- this query below is to try to understand a range of delivery times to then set boundaries to test
-- whether longer delivery times = worse reviews -- 

SELECT
    MIN(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)) AS min_delivery_days,
    MAX(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)) AS max_delivery_days,
    AVG(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- average delivery days = 12.56 days 
-- min delivery days = 0.5 days 
-- max delivery days = 209 days 


-- below query is to split different delivery times into range and see the different average review associated with each delivery range 

WITH cte AS (
    SELECT 
        JULIANDAY(order_delivered_customer_date)
        - JULIANDAY(order_purchase_timestamp) AS delivery_days,
        review_score
    FROM orders o
    JOIN order_reviews ore 
        ON ore.order_id = o.order_id
    WHERE order_delivered_customer_date IS NOT NULL
),
rang AS (
    SELECT 
        review_score,
        CASE
            WHEN delivery_days < 10 THEN 'Under 10 days'
            WHEN delivery_days < 15 THEN '10–14 days'
            WHEN delivery_days < 20 THEN '15–19 days'
            WHEN delivery_days < 27 THEN '20–26 days'
            ELSE '27+ days'
        END AS delivery_range
    FROM cte
)
SELECT 
    delivery_range,
    AVG(review_score) AS avg_review_score,
    COUNT(*) AS reviews
FROM rang 
GROUP BY delivery_range
ORDER BY avg_review_score desc



-- below query is to see which states have the largest amount of deliveries which take over 27days and the average review score in that state along with number of total deliveries --
SELECT 
    c.customer_state,
    COUNT(*) AS total_deliveries,
    COUNT(
        CASE 
            WHEN JULIANDAY(o.order_delivered_customer_date)
               - JULIANDAY(o.order_purchase_timestamp) >= 27
            THEN 1
        END
    ) AS deliveries_27_plus_days,
    ROUND(
        COUNT(
            CASE 
                WHEN JULIANDAY(o.order_delivered_customer_date)
                   - JULIANDAY(o.order_purchase_timestamp) >= 27
                THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_27_plus,
    ROUND(AVG(ore.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews ore 
    ON ore.order_id = o.order_id
JOIN customers c 
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;


-- below query identifies percentage of deliveries by each seller which take over 27 days to deliver and each sellers average review score 

WITH seller_orders AS (
    SELECT DISTINCT
        s.seller_id,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        ore.review_score
    FROM orders o
    JOIN order_reviews ore 
        ON ore.order_id = o.order_id
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    JOIN sellers s 
        ON s.seller_id = oi.seller_id
    WHERE o.order_delivered_customer_date IS NOT NULL
)

SELECT 
    seller_id,
    COUNT(*) AS total_deliveries,
    COUNT(
        CASE 
            WHEN JULIANDAY(order_delivered_customer_date)
               - JULIANDAY(order_purchase_timestamp) >= 27
            THEN 1
        END
    ) AS deliveries_27_plus_days,
    ROUND(
        COUNT(
            CASE 
                WHEN JULIANDAY(order_delivered_customer_date)
                   - JULIANDAY(order_purchase_timestamp) >= 27
                THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_27_plus,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM seller_orders

GROUP BY seller_id
HAVING COUNT(*) > 250
ORDER BY percentage_27_plus DESC;

-- identified seller 7c67e1448b00f6e969d365cea6b010ab to have highest percentage of deliveries taking 27+, 23%+

-- seller specific analysis - 7c67e1448b00f6e969d365cea6b010ab --

-- below query shows which categories sold by 7c67e1448b00f6e969d365cea6b010ab causes/has the most 27+ day deliveries

WITH cte AS (
    SELECT DISTINCT
        s.seller_id,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        oi.product_id
    FROM orders o
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    JOIN sellers s 
        ON s.seller_id = oi.seller_id
    WHERE o.order_delivered_customer_date IS NOT NULL
)

SELECT 
    cte.seller_id,
    ct.product_category_name_english,
    COUNT(*) AS deliveries_27_plus_days
FROM cte
JOIN products p 
    ON p.product_id = cte.product_id
JOIN category_translation ct 
    ON ct.product_category_name = p.product_category_name
WHERE cte.seller_id IN (
    '7c67e1448b00f6e969d365cea6b010ab')
AND JULIANDAY(cte.order_delivered_customer_date)
    - JULIANDAY(cte.order_purchase_timestamp) >= 27
GROUP BY 
    cte.seller_id,
    ct.product_category_name_english
ORDER BY 
    cte.seller_id,
    deliveries_27_plus_days DESC;

-- shows 210 office furniture delayed deliveries -- 

-- below query is to understand if specific products within office are causing most of the delayed deliveries for this problem seller

WITH cte AS (
    SELECT DISTINCT
        s.seller_id,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        oi.product_id
    FROM orders o
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    JOIN sellers s 
        ON s.seller_id = oi.seller_id
    WHERE o.order_delivered_customer_date IS NOT NULL
)

SELECT
    cte.product_id,
    COUNT(*) AS deliveries_27_plus_days
FROM cte
JOIN products p
    ON p.product_id = cte.product_id
JOIN category_translation ct
    ON ct.product_category_name = p.product_category_name
WHERE cte.seller_id = '7c67e1448b00f6e969d365cea6b010ab'
  AND ct.product_category_name_english = 'office_furniture'
  AND JULIANDAY(cte.order_delivered_customer_date)
      - JULIANDAY(cte.order_purchase_timestamp) >= 27
GROUP BY cte.product_id
ORDER BY deliveries_27_plus_days DESC;

-- identified that it is a range of products which causing long deliveries therefore is seller specific problem and not to do with products -- 


-- below is to see what percentage of the total companies delayed office furniture deliveries are contributed by the problem seller

WITH cte AS (
    SELECT DISTINCT
        oi.seller_id,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        oi.product_id
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
),

office_furniture_late AS (
    SELECT
        cte.seller_id,
        cte.order_id,
        cte.product_id
    FROM cte
    JOIN products p
        ON p.product_id = cte.product_id
    JOIN category_translation ct
        ON ct.product_category_name = p.product_category_name
    WHERE ct.product_category_name_english = 'office_furniture'
      AND JULIANDAY(cte.order_delivered_customer_date)
          - JULIANDAY(cte.order_purchase_timestamp) >= 27
)

SELECT
    COUNT(*) AS total_late_office_furniture_deliveries,

    SUM(CASE
        WHEN seller_id = '7c67e1448b00f6e969d365cea6b010ab'
        THEN 1
        ELSE 0
    END) AS target_seller_late_deliveries,

    ROUND(
        100.0 * SUM(CASE
            WHEN seller_id = '7c67e1448b00f6e969d365cea6b010ab'
            THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS percentage_of_all_late_office_furniture_deliveries

FROM office_furniture_late

-- 80.77% of all companies 27+ day office furniture deliveries are by problem seller -- 



-- below is to see what proportion of the companies total office furniture sales are made up by problem seller --


WITH cte AS (
    SELECT DISTINCT
        oi.seller_id,
        oi.order_id,
        oi.product_id
    FROM order_items oi
    JOIN orders o
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),

office_furniture_sales AS (
    SELECT
        cte.seller_id,
        cte.order_id,
        cte.product_id
    FROM cte
    JOIN products p
        ON p.product_id = cte.product_id
    JOIN category_translation ct
        ON ct.product_category_name = p.product_category_name
    WHERE ct.product_category_name_english = 'office_furniture'
)

SELECT
    COUNT(*) AS total_office_furniture_sales,

    SUM(CASE
        WHEN seller_id = '7c67e1448b00f6e969d365cea6b010ab'
        THEN 1
        ELSE 0
    END) AS seller_office_furniture_sales,

    ROUND(
        100.0 * SUM(CASE
            WHEN seller_id = '7c67e1448b00f6e969d365cea6b010ab'
            THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS seller_percentage_of_office_furniture_sales

FROM office_furniture_sales;

-- 70.35% of all office furniture sales are from problem seller, disproportionate to the amount of delayed deliveries by them -- 
