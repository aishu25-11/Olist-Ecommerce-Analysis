-- KPI CARDS
--  TOTAL UNIQUE CUSTOMERS
SELECT
COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- KPI TOTAL SALES
SELECT
COUNT(DISTINCT order_id) AS orders_items,
ROUND(SUM(price),2) AS total_sales
FROM order_items;

-- Total Number of Orders Delivered Successfully
SELECT
COUNT(order_id) AS Total_Delivered_Orders
FROM orders
WHERE
order_status = 'delivered';

-- Average Order Value
SELECT
CAST(SUM(payment_value) AS REAL) / COUNT(DISTINCT order_id) AS Average_Order_Value
FROM order_payments;

-- Total Revenue
SELECT
SUM(payment_value) AS Total_Revenue
FROM order_payments;
 
--  MAIN QUERIES
-- Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT kpi1.day_end,
CONCAT(
ROUND(kpi1.total_payment / (SELECT SUM(payment_value) FROM order_payments) * 100, 2),'%') AS percentage_payment_values
FROM ( SELECT ord.day_end,
SUM(pmt.payment_value) AS total_payment FROM order_payments AS pmt
JOIN ( SELECT DISTINCT order_id,
CASE
	WHEN WEEKDAY(order_purchase_timestamp) IN (5, 6) THEN 'Weekend'
	ELSE 'Weekday'
	END AS day_end
	FROM orders
	) AS ord
	ON ord.order_id = pmt.order_id
	GROUP BY ord.day_end
) AS kpi1;

-- Number of Orders with review score 5 and payment type as credit card.
SELECT 
COUNT(pmt.order_id) AS Total_Orders
FROM order_payments pmt
INNER JOIN order_reviews rev 
ON pmt.order_id = rev.order_id
WHERE rev.review_score = 5
AND pmt.payment_type = 'credit_card';

-- Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 
prod.product_category_name,
ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date,ord.order_purchase_timestamp)), 0) AS Avg_delivery_days
FROM orders ord
JOIN (
SELECT 
p.product_id,
oi.order_id,
p.product_category_name
FROM products p
JOIN order_items oi 
USING (product_id)
) AS prod
ON ord.order_id = prod.order_id
WHERE 
prod.product_category_name = 'pet_shop'
GROUP BY prod.product_category_name;

-- Average price and payment values from customers of sao paulo city
WITH orderItemsAvg AS (
SELECT 
ROUND(AVG(item.price)) AS avg_order_item_price
FROM order_items item
JOIN orders ord 
ON item.order_id = ord.order_id
JOIN customers cust 
ON ord.customer_id = cust.customer_id
WHERE cust.customer_city = 'Sao Paulo'
)
SELECT  
(SELECT avg_order_item_price FROM orderItemsAvg) AS avg_order_item_price,
ROUND(AVG(pmt.payment_value)) AS avg_payment_value
FROM order_payments pmt
JOIN orders ord 
ON pmt.order_id = ord.order_id
JOIN customers cust 
ON ord.customer_id = cust.customer_id
WHERE cust.customer_city = 'Sao Paulo';

-- Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT
rew.review_score,
ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date,ord.order_purchase_timestamp)), 0) AS avg_shipping_days
FROM orders AS ord
JOIN order_reviews AS rew
ON rew.order_id = ord.order_id
GROUP BY rew.review_score
ORDER BY rew.review_score;

-- Top 5 Best-Selling Product Categories (by items sold)
SELECT
t2.product_category_name_english,
COUNT(t1.order_item_id) AS Total_Items_Sold
FROM order_items AS t1
INNER JOIN products AS t3
ON t1.product_id = t3.product_id
INNER JOIN product_category_name AS t2
ON t3.product_category_name = t2.product_category_name
GROUP BY
t2.product_category_name_english
ORDER BY
Total_Items_Sold DESC
LIMIT 5;

-- Monthly sales by product category (top 10 categories)
SELECT 
date_format(o.order_purchase_timestamp,'%Y-%m') as yearmonth,
pcn.product_category_name_english as category,
round(sum(oi.price),2) as monthly_sale
FROM order_items oi
JOIN orders o 
on oi.order_id = o.order_id
join products p 
on oi.product_id = p.product_id 
left join product_category_name pcn
on p.product_category_name = pcn.product_category_name
group by yearmonth,category
order by yearmonth,monthly_sale desc
limit 10;

-- Top 10 sellers by SALES and number of distinct products sold
select 
s.seller_id,
round(sum(oi.price),2) sales,
count(distinct oi.product_id) total_products_sold
from sellers s
join order_items oi
on s.seller_id = oi.seller_id
group by seller_id
order by sales desc
limit 10;

-- Average delivery time in days between purchase and customer delivery
select 
count(order_id) orders,
round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp)),2) avg_delivery_days
from orders
where order_purchase_timestamp is not null 
and order_delivered_customer_date is not null;
SELECT
p.payment_type,
COUNT(*) AS payments_count,
round(SUM(p.payment_value),2) AS total_payment_value,
ROUND(AVG(p.payment_value), 2) AS avg_payment_value,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*)FROM order_payments WHERE payment_value IS NOT NULL), 2) AS percentage_of_payments
FROM order_payments p
WHERE p.payment_value IS NOT NULL
GROUP BY p.payment_type
ORDER BY total_payment_value DESC;

-- TOP 10 CITIES BY SALES
WITH order_revenue AS (
SELECT 
o.order_id,
LOWER(TRIM(c.customer_city)) AS city,
SUM(oi.price) AS order_sales
FROM orders o
JOIN customers c 
ON o.customer_id = c.customer_id
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.order_id, city
)
SELECT
city,
COUNT(*) AS orders_count,
ROUND(SUM(order_sales),2) AS total_sales
FROM order_revenue
GROUP BY city
ORDER BY total_sales DESC
LIMIT 10;

-- Average Order Value (AOV) = total sales / total orders
WITH sales_per_order AS (
  SELECT 
  order_id, 
  SUM(price) AS order_sales
  FROM order_items
  GROUP BY order_id
)
SELECT
  COUNT(*) AS total_orders,
  ROUND(SUM(order_sales),2) AS total_sales,
  ROUND(avg(order_sales), 2) AS avg_order_value
FROM sales_per_order;

-- REVIEW COUNT AND AVERAGE REVIEW SCORE
SELECT
  COUNT(*) AS reviews_count,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM order_reviews;
