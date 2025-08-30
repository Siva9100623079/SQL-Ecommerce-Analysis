-- 1. Total spend by each customer
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(p.price * o.quantity) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 2. Ranking customers by spend
WITH customer_sales AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(p.price * o.quantity) AS total_spent
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *,
       RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_sales;

-- 3. Running total of sales over time
SELECT o.order_date,
       SUM(p.price * o.quantity) AS daily_sales,
       SUM(SUM(p.price * o.quantity)) 
           OVER (ORDER BY o.order_date) AS running_total
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- 4. Customers who bought more than 1 category
WITH categories AS (
    SELECT o.customer_id, COUNT(DISTINCT p.category) AS category_count
    FROM Orders o
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY o.customer_id
)
SELECT c.first_name, c.last_name, category_count
FROM categories cat
JOIN Customers c ON cat.customer_id = c.customer_id
WHERE category_count > 1;

-- 5. Most popular product per city
WITH product_city AS (
    SELECT c.city, p.product_name,
           SUM(o.quantity) AS total_qty,
           RANK() OVER (PARTITION BY c.city ORDER BY SUM(o.quantity) DESC) AS rnk
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY c.city, p.product_name
)
SELECT city, product_name, total_qty
FROM product_city
WHERE rnk = 1;
