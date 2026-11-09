import pandas as pd
import matplotlib.pyplot as plt

# Load CSV files
customers = pd.read_csv("../01_Dataset/customers.csv")
products = pd.read_csv("../01_Dataset/products.csv")
categories = pd.read_csv("../01_Dataset/categories.csv")
orders = pd.read_csv("../01_Dataset/orders.csv")
order_items = pd.read_csv("../01_Dataset/order_items.csv")

# Convert dates
customers["registration_date"] = pd.to_datetime(customers["registration_date"])
orders["order_date"] = pd.to_datetime(orders["order_date"])

# Basic data-quality checks
for name, df in {
    "customers": customers,
    "products": products,
    "categories": categories,
    "orders": orders,
    "order_items": order_items
}.items():
    print(f"\n{name.upper()}")
    print("Shape:", df.shape)
    print("Missing values:")
    print(df.isnull().sum())

# Merge tables
sales = (
    order_items
    .merge(orders, on="order_id", how="left")
    .merge(products, on="product_id", how="left")
    .merge(categories, on="category_id", how="left")
    .merge(customers, on="customer_id", how="left")
)

# Revenue at item level
sales["revenue"] = sales["quantity"] * sales["unit_price"]

# Use delivered orders for business KPIs
delivered = sales[sales["status"] == "Delivered"].copy()

# KPIs
total_revenue = delivered["revenue"].sum()
total_orders = delivered["order_id"].nunique()
total_customers = delivered["customer_id"].nunique()
average_order_value = total_revenue / total_orders

print("\n--- BUSINESS KPIs ---")
print("Total Revenue:", round(total_revenue, 2))
print("Delivered Orders:", total_orders)
print("Customers:", total_customers)
print("Average Order Value:", round(average_order_value, 2))

# Category analysis
category_sales = (
    delivered.groupby("category_name", as_index=False)["revenue"]
    .sum()
    .sort_values("revenue", ascending=False)
)
print("\nRevenue by category:")
print(category_sales)

# Product analysis
top_products = (
    delivered.groupby("product_name", as_index=False)["revenue"]
    .sum()
    .sort_values("revenue", ascending=False)
    .head(10)
)
print("\nTop 10 products:")
print(top_products)

# Monthly trend
delivered["month"] = delivered["order_date"].dt.to_period("M").astype(str)
monthly_sales = (
    delivered.groupby("month", as_index=False)["revenue"]
    .sum()
)
print("\nMonthly sales:")
print(monthly_sales)

# City analysis
city_sales = (
    delivered.groupby("city", as_index=False)["revenue"]
    .sum()
    .sort_values("revenue", ascending=False)
)
print("\nRevenue by city:")
print(city_sales)

# Export analysis tables for Power BI if needed
category_sales.to_csv("category_sales.csv", index=False)
top_products.to_csv("top_products.csv", index=False)
monthly_sales.to_csv("monthly_sales.csv", index=False)
city_sales.to_csv("city_sales.csv", index=False)

# Visual 1: Monthly revenue
plt.figure(figsize=(10, 5))
plt.plot(monthly_sales["month"], monthly_sales["revenue"], marker="o")
plt.title("Monthly Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Visual 2: Revenue by category
plt.figure(figsize=(10, 5))
plt.bar(category_sales["category_name"], category_sales["revenue"])
plt.title("Revenue by Category")
plt.xlabel("Category")
plt.ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Visual 3: Top products
plt.figure(figsize=(10, 5))
plt.barh(top_products["product_name"], top_products["revenue"])
plt.title("Top 10 Products by Revenue")
plt.xlabel("Revenue")
plt.ylabel("Product")
plt.tight_layout()
plt.show()
