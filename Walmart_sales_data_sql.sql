-- CREATE database IF NOT exists Walmart_Data; --

Use Walmart_Data;


/*Data Wrangling: This is the first step where inspection of data is done to make sure NULL values 
and missing values are detected and data replacement methods are used to replace, missing or NULL values. 
Build a database 
Create table and insert the data.
Select columns with null values in them. There are no null values in our database as in creating the tables, we set NOT NULL for each field, hence null values are filtered out.*/

Create table if not exists sales (
invoice_id varchar(30) Not Null primary key,
branch varchar (5) NOT NULL,
city varchar(30) NOT NULL,
customer_type varchar (30) NOT NULL,
gender varchar (30) NOT NULL,
product_line varchar (100) NOT NULL,
unit_price decimal (10, 2) NOT NULL,
quantity INT not null,
VAT float (6 , 4) not null,
total decimal (12, 4) not null,
date datetime not null,
time time not null,
payment_method varchar (20) not null,
cogs decimal (10 , 2) not null,
gross_margin_pct Float (11 , 9),
gross_income decimal (12, 4 ) not null,
rating float (2, 1 )
);

Select * from sales

/*Feature Engineering: This will help use generate some new columns from existing ones.
Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.*/

SELECT 
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;


ALTER TABLE sales  Add column time_of_day varchar (20);

update sales 
SET time_of_day = (
 CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END 
);

Select * from sales


/*Add a new column named day_name that contains the extracted days of the week on which the given transaction 
took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.*/

-- day_name ---

select 
date,
DAYNAME(date) 
from sales;

alter table sales add column day_name varchar(20);

update sales 
SET day_name = DAYNAME(date);


/*Add a new column named month_name that contains the extracted months of the year on which the given 
transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.*/

month_name 

SELECT date, MONTHNAME(date) 
FROM sales;

alter table sales add column month_name varchar(10);

update sales 
SET month_name = monthname(date);

Select * from sales

/*--Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project.--*/


/*Generic Question
Q1 How many unique cities does the data have?*/

select distinct city from sales;

/*Generic Question
Q1 In which city is each branch??*/

select distinct branch from sales;

select distinct branch, city from sales;

/*Product
How many unique product lines does the data have?
What is the most common payment method?
What is the most selling product line?
What is the total revenue by month?
What month had the largest COGS?
What product line had the largest revenue?
What is the city with the largest revenue?
What product line had the largest VAT?
Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
Which branch sold more products than average product sold?
What is the most common product line by gender?
What is the average rating of each product line?
*/

-- Q1 How many unique product lines does the data have? --

select  Count(distinct product_line) from sales;


-- Q2. What is the most common payment method? --

select payment_method,
count(payment_method)  as cnt
from sales
group by payment_method
order by cnt Desc


-- Q3.What is the most selling product line?-- 

select product_line,
count(product_line)  as cnt
from sales
group by product_line
order by cnt Desc

-- Q4. What is the total revenue by month? --

select month_name as month,
sum(total) as total_revenue
from sales
group by month_name
order by total_revenue Desc;


-- Q5. What month had the largest COGS?--

select month_name as month,
sum(cogs) as largest_cogs
from sales
group by month_name
order by largest_cogs Desc;

-- Q6. What product line had the largest revenue?-- 

select product_line,
sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- Q7 What product line had the largest VAT? --

select product_line,
AVG(VAT) as AVG_VAT
from sales
group by product_line
order by AVG_VAT  desc;

-- Q8. What is the city with the largest revenue?-- 

select branch, city,
sum(total) as total_revenue
from sales
group by branch, city
order by total_revenue desc;


-- Q9 Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales??-- 

SELECT
    product_line,
    quantity,
    CASE
        WHEN quantity > avg_quantity THEN 'Good'
        ELSE 'Bad'
    END AS sales_status
FROM (
    SELECT
        product_line,
        quantity,
        AVG(quantity) OVER (PARTITION BY product_line) AS avg_quantity
    FROM sales
) AS subquery
ORDER BY quantity DESC;



select product_line


-- Q10, Which branch sold more products than average product sold? --

Select branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);


-- Q11. What is the most common product line by gender? --

select gender, product_line,
count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;


-- Q12 What is the average rating of each product line?--

select 
ROUND (avg(rating),1) as avg_rating,
product_line 
from sales
group by product_line
order by avg_rating desc;


Select * from sales

-- Sales -- 
/*Number of sales made in each time of the day per weekday
Which of the customer types brings the most revenue?
Which city has the largest tax percent/ VAT (Value Added Tax)?
Which customer type pays the most in VAT?*/

-- Q1 Number of sales made in each time of the day per weekday --

select time_of_day,
COUNT(*) as total_sales
from sales
WHERE day_name = "Monday"
group by time_of_day
order by time_of_day desc


-- Q2Which of the customer types brings the most revenue? --

Select customer_type,
Sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;


-- Q3 Which city has the largest tax percent/ VAT (Value Added Tax)?--

select city,
Avg(VAT) as largest_vat
from sales
group by city
order by largest_vat desc;


-- Q4 Which customer type pays the most in VAT? --

select customer_type,
Avg(VAT) as most_vat
from sales
group by customer_type
order by most_vat desc;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------- Customer ----------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1 How many unique customer types does the data have? --

select distinct customer_type
from sales;

-- Q2 How many unique payment methods does the data have? --

select distinct payment_method
from sales;

-- Q3 What is the most common customer type? -- 

select customer_type,
count(customer_type)  as cnt
from sales
group by customer_type
order by cnt Desc

-- Which customer type buys the most? -- 

Select customer_type,
Count(quantity) as buys_most
from sales 
group by customer_type
order by buys_most desc;


--  Q5 What is the gender of most of the customers? ---

select gender,
count(*) as gender_cnt
from sales
group by gender 
order by gender desc;


-- Q6 What is the gender distribution per branch? -- 

select  gender, branch,
count(*) as per_branch
from sales
where branch in ("A" ,"B" ,"C")
group by gender, branch
order by per_branch desc;

-- Q7 Which time of the day do customers give most ratings? ---

Select time_of_day,
Avg(rating) as most_ratings
from sales
group by time_of_day
order by most_ratings desc


--  Q8 Which time of the day do customers give most ratings per branch? --- 

Select time_of_day, branch,
Avg(rating) as most_ratings
from sales
WHERE branch in ('A')
group by time_of_day, branch
order by most_ratings desc

-- Q9 Which day fo the week has the best avg ratings? --

Select day_name, 
Avg(rating) as best_ratings
from sales
group by day_name
order by best_ratings desc



-- Q10 Which day of the week has the best average ratings per branch? --

Select day_name, branch,
Avg(rating) as best_ratings
from sales
WHERE branch in ('A')
group by day_name, branch
order by best_ratings desc
Select * from sales