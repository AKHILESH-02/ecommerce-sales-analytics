# E-Commerce Sales & Database Analysis

## Objective
Analyze e-commerce sales, customer behavior, product performance, and order trends using MySQL, Python/Pandas, and Power BI.

## Tools
- MySQL
- Python
- Pandas
- Matplotlib
- Power BI
- Excel/CSV
- Git/GitHub

## Dataset
The project contains five related tables:
- customers
- products
- categories
- orders
- order_items

## Data Model
Customers 1-to-many Orders.
Orders 1-to-many Order_Items.
Products 1-to-many Order_Items.
Categories 1-to-many Products.

## Workflow
Raw CSV → Data validation → MySQL → SQL analysis → Python analysis → Power BI dashboard.

## Business Questions
1. What is total revenue?
2. What is the monthly revenue trend?
3. Which categories generate the most revenue?
4. Which products sell the most?
5. Who are the top customers?
6. Which cities generate the most revenue?
7. What payment methods are most used?
8. What is the cancellation rate?
9. What is the average order value?
10. Which products have low/no sales?

## Dashboard Pages
### Executive Overview
Cards:
- Total Revenue
- Total Orders
- Total Customers
- Average Order Value
- Cancellation Rate

Charts:
- Monthly Revenue Line Chart
- Revenue by Category Bar Chart
- Revenue by City Map/Bar Chart
- Orders by Status Donut Chart

### Product Analysis
- Top 10 Products by Revenue
- Top 10 Products by Quantity
- Revenue by Category
- Product/Category slicers

### Customer Analysis
- Top 10 Customers
- Revenue by City
- Repeat Customers
- Customer revenue table

## Interview Explanation
"I built an e-commerce sales analytics project using MySQL, Python and Power BI. I designed a relational database with customers, products, categories, orders and order-items tables. I used SQL joins, aggregations, CTEs and window functions to answer business questions, used Pandas for data validation and analysis, and created a Power BI dashboard for revenue, product, customer and order performance."

## Important
Do not claim that the project is production data. The dataset is synthetic and created for portfolio/practice purposes.
