use ecommerce;
select * from customers;
DESC CUSTOMERS;
ALTER TABLE CUSTOMERS
CHANGE ï»¿customer_id customer_id text;
select * from geolocation;
desc geolocation;
ALTER TABLE geolocation
CHANGE ï»¿geolocation_zip_code_prefix zip_prefix INT;
select * from order_items;
desc order_items;
ALTER TABLE order_items
CHANGE ï»¿order_id  order_id text;
select * from order_payments;
desc order_payments;
ALTER TABLE order_payments
CHANGE ï»¿order_id order_id text;
select * from order_reviews;
desc order_reviews;
alter table order_reviews
change ï»¿review_id review_id text;
select * from orders;
desc orders;
alter table orders
change ï»¿order_id order_id text;
UPDATE orders
SET order_purchase_timestamp = STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i');
ALTER TABLE orders
MODIFY order_purchase_timestamp DATETIME;
UPDATE orders
SET order_delivered_customer_date = STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i');
alter table orders
modify order_delivered_customer_date datetime;
desc product_category_name;
alter table product_category_name
change ï»¿product_category_name product_category_name text;
desc products;
alter table products
change ï»¿product_id product_id text;
desc sellers;
alter table sellers
change ï»¿seller_id seller_id text;
