-- Exploratory data analysis
SELECT
    COUNT(DISTINCT Branch) 
FROM
	walmart;


SELECT
	payment_method,
    COUNT(payment_method)
FROM
	walmart
GROUP BY payment_method;

-- Business problems
-- What are the different payment methods, and how many transactions and items were sold with each method?

SELECT
	payment_method,
	COUNT(*) AS transactions,
    SUM(quantity) AS quantity_sold
FROM
	walmart
GROUP BY payment_method;

-- Which category received the highest average rating in each branch?

SELECT
	*
FROM (SELECT
	Branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank_num
FROM
	walmart 
GROUP BY Branch, category) sub
WHERE rank_num = 1;

-- What is the busiest day of the week for each branch based on transaction volume?

SELECT
	*
FROM
(SELECT
	Branch,
    COUNT(*) AS transactions,
    DAYNAME(STR_TO_DATE(date, "%d/%m/%Y")) AS busiest_day_of_the_month,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_num
FROM
	walmart
GROUP BY Branch, busiest_day_of_the_month) sub
WHERE rank_num = 1;

-- How many items were sold through each payment method?

SELECT
	payment_method,
    SUM(quantity) AS items_sold
FROM
	walmart 
GROUP BY payment_method;

-- What are the average, minimum, and maximum ratings for each category in each city?

SELECT
	City,
    category,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM
	walmart 
GROUP BY City, category;

-- What is the total profit for each category, ranked from highest to lowest?

SELECT
	category,
    ROUND(SUM(unit_price * quantity * profit_margin), 2) AS total_profit
FROM
	walmart 
GROUP BY category
ORDER BY total_profit DESC;

-- What is the most frequently used payment method in each branch?

SELECT
	*
FROM
(SELECT
	Branch,
    payment_method,
    COUNT(*) AS Transactions,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_num
FROM
	walmart
GROUP BY Branch, payment_method) sub
WHERE rank_num = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;