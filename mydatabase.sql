-- =========================
-- DATABASE & TABLE SETUP
-- =========================

-- Drop the database if it already exists to start fresh
DROP DATABASE IF EXISTS MyDatabase;

-- Create a new database named 'MyDatabase'
CREATE DATABASE MyDatabase;

-- Switch context to use the newly created database
USE MyDatabase;

-- Drop 'customers' table if it already exists to avoid conflicts
DROP TABLE IF EXISTS customers;

-- Create 'customers' table with basic customer info
CREATE TABLE customers (
    id INT NOT NULL,                         -- Unique customer ID (Primary Key)
    first_name VARCHAR(50),                 -- First name of customer
    country VARCHAR(50),                    -- Customer's country
    score INT,                              -- Customer's score (could be loyalty, engagement, or performance metric)
    PRIMARY KEY (id)                        -- Ensures 'id' is unique and not null
);

-- Insert sample records into 'customers' table
INSERT INTO customers (id, first_name, country, score) VALUES
    (1, 'Maria', 'Germany', 350),
    (2, ' John', 'USA', 900),               -- Note: extra space before 'John'; good for testing string cleanup
    (3, 'Georg', 'UK', 750),
    (4, 'Martin', 'Germany', 500),
    (5, 'Peter', 'USA', 0);                 -- Example of a customer with 0 score, useful for filtering tests

-- Drop 'orders' table if it already exists
DROP TABLE IF EXISTS orders;

-- Create 'orders' table with order-related details
CREATE TABLE orders (
    order_id INT NOT NULL,                  -- Unique order ID (Primary Key)
    customer_id INT NOT NULL,              -- ID of customer who placed the order (foreign key to 'customers')
    order_date DATE,                        -- Date of order placement
    sales INT,                              -- Total sales amount of the order
    PRIMARY KEY (order_id)
);

-- Insert sample order records into 'orders'
INSERT INTO orders (order_id, customer_id, order_date, sales) VALUES
    (1001, 1, '2021-01-11', 35),
    (1002, 2, '2021-04-05', 15),
    (1003, 3, '2021-06-18', 20),
    (1004, 6, '2021-08-31', 10);            -- Order from a non-existent customer ID (used to demonstrate unmatched rows)

-- View all rows in 'customers'
SELECT * FROM customers;

-- View all rows in 'orders'
SELECT * FROM orders;

-- View specific columns from 'customers'
SELECT first_name, country, score FROM customers;

-- =========================
-- WHERE CLAUSE (Row Filtering)
-- =========================

-- Get customers with score above 500
SELECT first_name, country FROM customers WHERE score > 500;

-- Get customers with non-zero scores
SELECT first_name FROM customers WHERE score != 0;

-- Get customers from Germany
SELECT first_name FROM customers WHERE country = "Germany";

-- =========================
-- ORDER BY (Sorting)
-- =========================

-- Sort by score in descending order (highest first)
SELECT * FROM customers ORDER BY score DESC;

-- Sort by score in ascending order (lowest first)
SELECT * FROM customers ORDER BY score;

-- Sort by country (A-Z), and within country, by score descending
SELECT * FROM customers ORDER BY country ASC, score DESC;

-- =========================
-- GROUP BY (Aggregating rows)
-- =========================
-- RULE: All columns in SELECT must be either aggregated or present in GROUP BY
-- Used to aggregate data and perform calculations like SUM, COUNT, AVG grouped by specific columns

-- Get total score per country
SELECT country, SUM(score) AS total FROM customers GROUP BY country;

-- Get total score and number of customers for each country
SELECT country, SUM(score) AS total_score, COUNT(*) AS total_customers
FROM customers GROUP BY country;

-- Apply filtering *before* and *after* aggregation
-- WHERE filters rows before grouping
-- HAVING filters aggregated results (HAVING only works with aggregate functions)
SELECT country, SUM(score) AS total_score, COUNT(*) AS total_customers
FROM customers 
WHERE score > 400
GROUP BY country
HAVING SUM(score) > 800;

-- Get average score per country (excluding score = 0), only return those with avg > 450
SELECT 
    country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 450;

-- =========================
-- DISTINCT, LIMIT, STATIC VALUES
-- =========================

-- Get unique countries (no repetition)
SELECT DISTINCT country FROM customers;

-- Get top 3 customers by score
SELECT * FROM customers ORDER BY score DESC LIMIT 3;

-- Get bottom 2 customers by score
SELECT * FROM customers ORDER BY score LIMIT 2;

-- Get the last 2 orders placed (latest dates first)
SELECT * FROM orders ORDER BY order_date DESC LIMIT 2;

-- Use of static values (useful in testing or placeholder queries)
SELECT 123 AS static_number;
SELECT "hello" AS static_string;

-- Add a constant label to every row (useful in UNIONs or flags)
SELECT 
id,
first_name,
'new customer' AS customer_type
FROM customers;

-- =========================
-- DDL: CREATE, ALTER, DROP TABLE
-- =========================

-- Create a new table 'persons'
CREATE TABLE persons(
	 id INT NOT NULL,
     person_name VARCHAR(50) NOT NULL,
     birth_date DATE,
     phone VARCHAR(10) NOT NULL,
     CONSTRAINT pk_persons PRIMARY KEY(id)
);

-- View all data from 'persons'
SELECT * FROM persons;

-- Add a new column 'email' to 'persons'
ALTER TABLE persons ADD email VARCHAR(50) NOT NULL;

-- Remove the column 'phone' from 'persons'
ALTER TABLE persons DROP COLUMN phone;

-- Drop the entire 'persons' table
DROP TABLE persons;

-- =========================
-- DML: INSERT, UPDATE, DELETE, TRUNCATE
-- =========================

-- Insert multiple records into 'customers'
INSERT INTO customers (id, first_name, country, score)
VALUES (6, "sanya", "india", 1000), (7, "kartik", "india", NULL); 

-- View updated customer list
SELECT * FROM customers;

-- Insert into 'persons' using SELECT from 'customers'
INSERT INTO persons(id, person_name, birth_date, phone)
SELECT 
id,
first_name,
NULL,
'Unkknown'
FROM customers;

-- Update specific birth date for a person
UPDATE persons SET birth_date = '2004-01-07' WHERE id = '6';

-- Update customer score to 0
UPDATE customers SET score = 0 WHERE id = 7;

-- Delete customers with id > 6
DELETE FROM customers WHERE id > 6;

-- Remove all data from 'persons' table but keep structure
TRUNCATE TABLE persons;

-- =========================
-- ADVANCED FILTERING
-- =========================

-- Logical and comparison operators
SELECT first_name AS usa_people FROM customers WHERE country = 'USA';
SELECT * FROM customers WHERE country != 'Germany';
SELECT * FROM customers WHERE score >= 500;
SELECT * FROM customers WHERE score <= 500;

-- Using AND, OR, NOT for complex filters
SELECT * FROM customers WHERE country = 'USA' AND score > 500;
SELECT * FROM customers WHERE country = 'USA' OR score > 500;
SELECT * FROM customers WHERE NOT score < 500;
SELECT * FROM customers WHERE NOT country = 'USA';

-- BETWEEN operator (inclusive range)
SELECT * FROM customers WHERE score BETWEEN 100 AND 500;

-- IN/NOT IN for set matching
SELECT * FROM customers WHERE country IN ('Germany', 'USA');
SELECT * FROM customers WHERE NOT country IN ('Germany', 'USA');

-- LIKE pattern matching
-- % = any characters, _ = exactly one character
SELECT * FROM customers WHERE first_name LIKE 'M%';     -- Starts with 'M'
SELECT * FROM customers WHERE first_name LIKE '%N';     -- Ends with 'N'
SELECT * FROM customers WHERE first_name LIKE '%r%';    -- Contains 'r'
SELECT * FROM customers WHERE first_name LIKE '__r%';   -- 3rd letter is 'r'

-- =========================
-- JOINS OVERVIEW
-- =========================

-- No join: view tables separately
SELECT * FROM customers;
SELECT * FROM orders;

-- INNER JOIN: only matching records in both tables based on condition
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
INNER JOIN orders AS o ON c.id = o.customer_id;

-- LEFT JOIN: all from left + matched from right; unmatched right values will be NULL
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
LEFT JOIN orders AS o ON c.id = o.customer_id;

-- RIGHT JOIN: all from right + matched from left; unmatched left values will be NULL
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c 
RIGHT JOIN orders AS o ON c.id = o.customer_id;

-- RIGHT JOIN simulated using LEFT JOIN (just switch table positions)
SELECT c.id, c.first_name, o.order_id, o.sales
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.id;

-- FULL OUTER JOIN simulated with UNION (all records from both sides)
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
LEFT JOIN orders AS o ON c.id = o.customer_id
UNION
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
RIGHT JOIN orders AS o ON c.id = o.customer_id;

-- =========================
-- ANTI JOINS
-- =========================

-- LEFT ANTI JOIN: customers with no orders (find unmatched from left table)
SELECT * FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id
WHERE orders.customer_id IS NULL;

-- RIGHT ANTI JOIN: orders with no customers (find unmatched from right table)
SELECT * FROM customers
RIGHT JOIN orders ON customers.id = orders.customer_id
WHERE customers.id IS NULL;

-- Alternate way to get orders with no matching customers (anti-join)
SELECT * FROM orders 
LEFT JOIN customers ON orders.customer_id = customers.id
WHERE customers.id IS NULL;

-- Get only customers who placed an order (avoid INNER JOIN by using condition)
SELECT * FROM customers AS c
LEFT JOIN orders AS o ON c.id = o.customer_id
WHERE order_id IS NOT NULL;

-- CROSS JOIN: every combination of rows from both tables (Cartesian product)
SELECT * FROM customers CROSS JOIN orders;

-- =========================
-- HOW TO CHOOSE A JOIN
-- =========================
-- INNER JOIN  -> only matching data
-- LEFT JOIN   -> all rows from left + matching from right
-- RIGHT JOIN  -> all rows from right + matching from left
-- FULL JOIN   -> everything from both sides (simulate with UNION)
-- ANTI JOIN   -> mismatches only (use NULL check)
-- CROSS JOIN  -> every combination (Cartesian product)

-- =========================
-- TRUE OR FALSE INTERVIEW TIP
-- =========================
-- TRUE: The HAVING clause is used **only with aggregate functions** like SUM(), COUNT(), AVG(), etc.
-- HAVING is applied **after** GROUP BY, unlike WHERE which is used **before** grouping.
-- It’s used to filter groups, not individual rows.
