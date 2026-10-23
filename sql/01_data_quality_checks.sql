SELECT seller_id , count(*)  -- checking duplicates, was repeated for all relevant sections -- 
from sellers
group by seller_id
HAVING count(*) > 1

SELECT  --- identifying nulls, was repeated for all relevant data --
count(*) as total_rows,
count(customer_id),
count(customer_unique_id),
count(customer_zip_code_prefix),
count(customer_city), 
count(customer_state)
from customers -- no nulls -- 


SELECT  --- identifying order nulls ---
count(*) as total_rows,
count(customer_id),
count(order_id),
count(order_status),
count(order_purchase_timestamp), 
count(order_approved_at),
count(order_delivered_carrier_date),
count(order_delivered_customer_date),
count(order_estimated_delivery_date)
from orders 

-- large amount of nulls (2965) identified in order_delivered_customer_date column, investigaite nulls -- 

SELECT  -- checking status of all rows which gave null values -- 
    order_status,
    COUNT(*) AS orders
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY orders DESC
-- 2957 orders have order_status which explain order_delivered_customer_date NULL however 8 orders show status as delivered meaning possible error in data quality -- 


  
 SELECT COUNT(*)  -- checking for empty strings in sellers, was completed for all relevant sections -- 
  FROM sellers
  WHERE TRIM(seller_city) = ' '  -- none -- 


-- date checks --

SELECT COUNT(*) -- date checks -- 
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;
-- 166 values where order purchase was after delivered to carrier -- 

SELECT -- investigating the 166 values from above -- 
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp
ORDER BY order_purchase_timestamp;

-- A small number of orders contained delivery-carrier timestamps earlier than the recorded purchase timestamp. These records were retained because the discrepancies were small and did not materially affect the broader order timeline. -- 

SELECT COUNT(*)
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;
-- 23 values where order delivered to carrier after customer -- 

SELECT -- identifying the nature/size of the inconsistencies in timestamps of deliveries to carrier and customer -- 
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date
ORDER BY order_purchase_timestamp;

-- 23 delivered orders have a customer delivery timestamp earlier than the recorded carrier delivery timestamp. These records were retained in the raw dataset but excluded from analyses that rely on the chronological relationship between carrier and customer delivery dates. -- 


