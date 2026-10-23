-- query to see what years the database spread over -- 

SELECT min(order_purchase_timestamp), max(order_purchase_timestamp)
FROM orders

-- START date:  2016-09-04 21:15:19 --
-- END date: 2018-10-17 17:30:18 -- 


--  which Olist product category sells the best -- 

SELECT p.product_category_name, 
ct.product_category_name_english,
COUNT(*) as items_sold
FROM order_items oi 
LEFT JOIN products p 
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY p.product_category_name, ct.product_category_name_english
order by items_sold DESC


-- which state is the highest selling state -- 

SELECT c.customer_state, COUNT(*) as items_sold
FROM order_items oi
JOIN orders o  ON o.order_id=oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_state
order by count(*) DESC, c.customer_state

-- SP is highest selling state 47449, only top 3 (SP, RJ, MG) are over 10k sales)


-- number of sales in top 15 selling product category and percentage of total sales in olist


select count(*) as sales,  
round(count(*)*100.0/sum(count(*) ) OVER (), 2)as percentage,
 ct.product_category_name_english, row_number () OVER(order by count(*)DESC) as n_rank
from category_translation ct
JOIN products p on p.product_category_name=ct.product_category_name
JOIN order_items oi ON oi.product_id=p.product_id
group by ct.product_category_name_english
LIMIT 15

-- clear favourite in the top ranks in most states is health_beauty and 
--- bed_bath_table,  BA had large amount of sports_leisure sales as did other states -- 
-- furniture decor also featured as a high category across multiple states including RJ
-- no states had a surprisingly high selling product category compared to average levels across the entire country

-- below shows top 15 product category sales (across whole company) by state and with percentage of total product category sales by state

with state AS(
SELECT
    c.customer_state,
    COUNT(*) AS sales,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY c.customer_state),
        2
    ) AS percentage,
    ct.product_category_name_english,
    ROW_NUMBER() OVER (
        PARTITION BY c.customer_state
        ORDER BY COUNT(*) DESC
    ) AS n_rank
FROM category_translation ct
JOIN products p
    ON p.product_category_name = ct.product_category_name
JOIN order_items oi
    ON oi.product_id = p.product_id
JOIN orders o
    ON o.order_id = oi.order_id
JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_state,
    ct.product_category_name_english
ORDER BY
    c.customer_state,
    sales DESC
	)
	
	SELECT customer_state, sales, percentage, product_category_name_english, n_rank
	from state
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
    'electronics'
) AND n_rank <= 5



-- Seller revenue/sales section --

select COUNT(*) from order_items

-- total sales = 112650 -- 
-- now to work out percentage of sales made by the top 10 and top 5 sellers -- 

WITH ranked AS (
select count(*) as sales,  s.seller_id, dense_rank () OVER (order by count(*) desc) as seller_rank
from order_items oi
JOIN orders o ON o.order_id=oi.order_id
JOIN sellers s ON s.seller_id=oi.seller_id
group by s.seller_id
order by count(*) desc
) 

select ROUND(sum((sales)*100.0 /112650), 2) as percentage_of_sales
from ranked 
where seller_rank <= 15
-- 18245 sales from top 13 -- 
-- 18.55 % of all sales were made from the top 13 sellers
-- 14.15% of all sales were made by top 10 sellers
-- 8.24% of all sales were made by top 5 sellers 

-- Findings:
-- Sales are relatively distributed across the seller base rather than being
-- heavily concentrated among a small number of sellers.
-- The top 5 sellers account for 8.24% of all items sold, while the top 10
-- account for 14.15%.
-- This suggests that Olist is not heavily dependent on a small number of
-- high-volume sellers.


-- now i am using the same query which shows the largest sellers by items sold but including product revenue
-- and freight revenue and ranking them 

select count(*) as sales,  s.seller_id, dense_rank () OVER (order by count(*) desc) as seller_rank,
sum(oi.price) as total_product_rev, 
dense_rank () over (order by sum(oi.price) DESC) as product_rev_rank,
sum(oi.freight_value) as total_freight_rev, 
dense_rank() over (order by sum(oi.freight_value) DESC) as freight_rev_rank,
sum(oi.freight_value + oi.price) AS total_seller_revenue,
dense_rank() over (order by sum(oi.freight_value + oi.price)DESC) as total_rev_rank
from order_items oi
JOIN orders o ON o.order_id=oi.order_id
JOIN sellers s ON s.seller_id=oi.seller_id
group by s.seller_id
order by total_rev_rank asc

- after ranking every category, (items sold, product revenue, freight revenue and total revenue) it
-- shows that all the top 10 in product revenue are also in the top 10 for total revenue but not the same order.
-- seller ranked 7 in total_rev_rank only sold 340 products and produced 7th highest total revenue
-- this could therefore be a seller to look to work with and promote. looking further into seasonal selling patterns
-- of this seller along with region this seller performed well would be helpful

-- Seller ranked 7th in total_rev_rank sold only 340 products but generated the
-- 7th highest total sales value.
-- This suggests that the seller's products had a relatively high value per sale
-- compared with many higher-volume sellers.
-- This could make the seller a potential candidate for further investigation
-- and targeted promotion on the Olist marketplace.
-- Further analysis of this seller's product categories, seasonal sales patterns
-- and the regions in which they perform strongly could help determine whether
-- their success could be replicated or expanded.
-- and delivery performance to determine whether their high sales value is
-- accompanied by strong customer satisfaction and reliable service.



