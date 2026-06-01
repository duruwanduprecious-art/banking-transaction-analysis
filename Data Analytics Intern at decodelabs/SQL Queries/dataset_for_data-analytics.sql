--- Creating dataset table
CREATE TABLE dataset_for_data_analytics(
order_id VARCHAR(20),
order_date DATE,
customer_id VARCHAR(20),
product VARCHAR(20),
quantity INT,
unit_price NUMERIC(12,2),
shipping_address VARCHAR(50),
payment_method VARCHAR(20),
order_status VARCHAR(20),
tracking_number VARCHAR(50),
items_in_cart INT, 
coupon_code VARCHAR(20),
referral_source VARCHAR(20),
total_price NUMERIC(12,2)
); 


--- Importing the dataset
COPY dataset_for_data_analytics(
order_id,
order_date,
customer_id,
product,
quantity,
unit_price,
shipping_address,
payment_method,
order_status,
tracking_number,
items_in_cart, 
coupon_code,
referral_source,
total_price
)
FROM 'C:\Data Analytics Intern at decodelabs\Cleaned data\Cleaned_dataset_for Data Analytics.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM dataset_for_data_analytics

