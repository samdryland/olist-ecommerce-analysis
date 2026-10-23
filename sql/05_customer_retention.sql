-- this next section is analysing customer retention by seeing how many customers bought more than once
-- and seeing if there is any pattern in these customers to try to exploit and target to incrase repeat buying.

SELECT count(distinct customer_unique_id)
from customers

-- this query shows there are 96,096 individual customers in the dataset


- below is to understand how many of those 96k customers ordered twice or more

with repeat as (
select customer_unique_id, count(distinct o.order_id) as buys 
from customers c
join orders o ON c.customer_id=o.customer_id
group by customer_unique_id
order by count(distinct o.customer_id) desc
)

select count(case when buys >= 2 then customer_unique_id END) AS repeat_customers,
COUNT(case when buys < 2 then customer_unique_id END) AS one_time_customer
from repeat 


--  only 2997 customers put 2+ orders in, that is 3.12% of customers. extremely small amount.


-- now to understand the split of repeat ordering customers to see how many bought more than 2 times -- 

with num AS (
select customer_unique_id, count(distinct o.order_id) as buys 
from customers c
join orders o ON c.customer_id=o.customer_id
group by customer_unique_id
order by count(distinct o.customer_id) desc
)

SELECT 
COUNT( CASE when buys = 2 then 1 END) AS two_orders,
COUNT(CASE when buys=3 then 1 END) as three_orders,
COUNT(CASE when buys=4 then 1  END) as four_orders,
COUNT(CASE when buys=5 then 1  END) as five_orders,
COUNT(CASE when buys>5 and buys<11 then 1  END) as between_six_and_ten_orders,
COUNT(CASE when buys>10 then 1  END) as eleven_plus_orders
from num
where buys > 1



-- below is to see which categories had the highest repeat purchase rate and repeat purchase volume, note that is within that category 
  -- e.g. buying 2 things from the same category on separate occasions -- 

  
WITH customer_category_orders AS (
    SELECT DISTINCT
        c.customer_unique_id,
        oi.product_id,
        ct.product_category_name_english,
        o.order_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
		JOIN category_translation ct 
		ON ct.product_category_name=p.product_category_name
),

category_customer_counts AS (
    SELECT
        product_category_name_english,
        customer_unique_id,
        COUNT(DISTINCT order_id) AS number_of_orders
    FROM customer_category_orders
    GROUP BY
        product_category_name_english,
        customer_unique_id
)

SELECT
    product_category_name_english,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN number_of_orders >= 2 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN number_of_orders >= 2 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM category_customer_counts

GROUP BY product_category_name_english
ORDER BY repeat_purchase_rate DESC
