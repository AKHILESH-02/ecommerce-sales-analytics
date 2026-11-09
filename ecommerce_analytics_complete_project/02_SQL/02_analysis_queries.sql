USE ecommerce_analytics;

-- 1. Total orders
SELECT COUNT(*) AS total_orders FROM orders;

-- 2. Total customers
SELECT COUNT(*) AS total_customers FROM customers;

-- 3. Total products
SELECT COUNT(*) AS total_products FROM products;

-- 4. Total revenue from delivered orders
SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered';

-- 5. Revenue by category
SELECT c.category_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Delivered'
GROUP BY c.category_name
ORDER BY revenue DESC;

-- 6. Top 10 products by quantity sold
SELECT p.product_name,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- 7. Top 10 products by revenue
SELECT p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 8. Monthly revenue
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- 9. Orders by status
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 10. Sales by payment method
SELECT o.payment_method,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY o.payment_method
ORDER BY revenue DESC;

-- 11. Top 10 customers by revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 10;

-- 12. Revenue by city
SELECT c.city,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY revenue DESC;

-- 13. Average order value
SELECT ROUND(
    SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2
) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered';

-- 14. Customers with more than 5 orders
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 5
ORDER BY order_count DESC;

-- 15. Products never ordered
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- 16. Cancellation rate
SELECT ROUND(
    100.0 * SUM(status = 'Cancelled') / COUNT(*), 2
) AS cancellation_rate_percent
FROM orders;

-- 17. Revenue contribution by category
WITH category_sales AS (
    SELECT c.category_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    WHERE o.status = 'Delivered'
    GROUP BY c.category_name
)
SELECT category_name,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;

-- 18. Rank products within each category
WITH product_sales AS (
    SELECT c.category_name,
           p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    WHERE o.status = 'Delivered'
    GROUP BY c.category_name, p.product_id, p.product_name
)
SELECT category_name, product_name,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (
           PARTITION BY category_name ORDER BY revenue DESC
       ) AS category_rank
FROM product_sales;

-- 19. Monthly revenue with month-over-month change
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(
           100 * (revenue - LAG(revenue) OVER (ORDER BY month))
           / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
       ) AS mom_growth_percent
FROM monthly
ORDER BY month;

-- 20. Repeat customers
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) x;

-- 21. Customer lifetime revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS lifetime_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_revenue DESC;
