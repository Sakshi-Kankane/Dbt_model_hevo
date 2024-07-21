{{
  config(
    materialized='table'
  )
}}

WITH customers_cte AS (
    SELECT
        id AS customer_id,
        first_name,
        last_name
    FROM LANDING_ZONE_RAW_CUSTOMERS
),

orders_cte AS (
    SELECT
        user_id AS customer_id,
        id as order_id,
        order_date,
        COUNT(*) AS number_of_orders
    FROM LANDING_ZONE_RAW_ORDERS
    GROUP BY user_id,id,order_date
),

payments_cte AS (
    SELECT
        order_id,
        SUM(amount) AS customer_lifetime_value
    FROM LANDING_ZONE_RAW_PAYMENTS
    GROUP BY order_id
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    min(o.order_date) as first_order,
    max(o.order_date) as most_recent_order,
    SUM(COALESCE(o.number_of_orders, 0)) AS number_of_orders,
    SUM(COALESCE(p.customer_lifetime_value, 0)) AS customer_lifetime_value
FROM customers_cte c
LEFT JOIN orders_cte o ON c.customer_id = o.customer_id
LEFT JOIN payments_cte p ON o.order_id = p.order_id
group by 1,2,3
order by 1