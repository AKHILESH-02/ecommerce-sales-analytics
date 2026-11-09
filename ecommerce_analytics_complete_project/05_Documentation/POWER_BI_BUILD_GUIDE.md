# Power BI Build Guide

## Recommended relationships
Customers[customer_id] 1 → * Orders[customer_id]
Categories[category_id] 1 → * Products[category_id]
Products[product_id] 1 → * Order_Items[product_id]
Orders[order_id] 1 → * Order_Items[order_id]

## Core measures

Total Revenue =
CALCULATE(
    SUMX(
        Order_Items,
        Order_Items[quantity] * Order_Items[unit_price]
    ),
    Orders[status] = "Delivered"
)

Total Orders =
CALCULATE(
    DISTINCTCOUNT(Orders[order_id]),
    Orders[status] = "Delivered"
)

Total Customers =
DISTINCTCOUNT(Orders[customer_id])

Average Order Value =
DIVIDE([Total Revenue], [Total Orders])

Cancelled Orders =
CALCULATE(
    DISTINCTCOUNT(Orders[order_id]),
    Orders[status] = "Cancelled"
)

Cancellation Rate =
DIVIDE([Cancelled Orders], DISTINCTCOUNT(Orders[order_id]))

Units Sold =
CALCULATE(
    SUM(Order_Items[quantity]),
    Orders[status] = "Delivered"
)

## Page 1: Executive Dashboard
Top cards:
Total Revenue | Total Orders | Total Customers | AOV | Cancellation Rate

Charts:
1. Line chart: Order Date vs Total Revenue
2. Clustered bar: Category vs Total Revenue
3. Bar chart: City vs Total Revenue
4. Donut: Order Status vs Order Count
5. Column chart: Payment Method vs Revenue

Slicers:
- Date
- Category
- City
- Payment Method

## Page 2: Product Analysis
1. Top 10 Products by Revenue
2. Top 10 Products by Units Sold
3. Category revenue
4. Product detail table
5. Category slicer

## Page 3: Customer Analysis
1. Top 10 Customers by Revenue
2. Revenue by City
3. Customer order frequency
4. Customer detail table
5. City slicer

## Dashboard advice
Keep each page clean. Use 4–6 major visuals rather than filling the page with charts. Use consistent number formatting and meaningful titles.
