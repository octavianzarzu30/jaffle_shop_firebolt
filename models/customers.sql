WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),
customer_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order,
        MAX(order_date) AS most_recent_order,
        COUNT(order_id) AS number_of_orders
    FROM orders
    GROUP BY 1
),
customer_payments AS (
    SELECT
        orders.customer_id,
        SUM(amount) AS total_amount
    FROM payments
    LEFT JOIN orders USING (order_id)
    GROUP BY 1
),
final AS (
    SELECT
        customers.customer_id,
        customers.first_name,
        customers.lASt_name,
        customer_orders.first_order,
        customer_orders.most_recent_order,
        customer_orders.number_of_orders,
        customer_payments.total_amount AS customer_lifetime_value
    FROM customers
    LEFT JOIN customer_orders ON customer_orders.customer_id = final.customer_id
    LEFT JOIN customer_payments ON customer_payments.customer_id = final.customer_id
)
SELECT * FROM final
