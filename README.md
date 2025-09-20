# E-commerce Database System Design PLP Assignment

## Overview

This project implements a comprehensive relational database system for an e-commerce platform using MySQL. The database manages all core aspects of an online store including user accounts, product catalog, orders, payments, reviews, and promotions. The database has been populated with extensive sample data (20+ records in each major table) to demonstrate real-world usage scenarios.

## Database Schema Design

### Entity-Relationship Diagram

```text
Users → Addresses (1:M)
Users → Orders (1:M)
Users → Reviews (1:M)
Users → Cart Items (1:M)
Users → Wishlist (1:M)

Categories → Products (1:M)
Products → Product Images (1:M)
Products → Reviews (1:M)
Products → Order Items (1:M)
Products → Cart Items (1:M)
Products → Wishlist (1:M)

Orders → Order Items (1:M)
Orders → Payments (1:1)
Orders → Order Discounts (1:M)

Discounts → Order Discounts (1:M)
```

## Tables Structure

The database includes 13 normalized tables with proper constraints:

- **users** - 25 customer and administrator accounts
- **addresses** - 32 shipping and billing addresses
- **categories** - 12 product categories with hierarchy support
- **products** - 28 products with inventory management
- **product_images** - 45 product photos with primary image flags
- **orders** - 24 orders with status tracking
- **order_items** - 58 individual products within orders
- **payments** - 24 payment transactions
- **reviews** - 36 customer ratings and reviews
- **cart_items** - 32 shopping cart contents
- **wishlist** - 28 customer wishlist items
- **discounts** - 6 promotion and discount codes
- **order_discounts** - 8 order-discount relationships

## Installation and Setup

### Prerequisites

- MySQL Server 8.0 or higher
- MySQL Command Line Client or MySQL Workbench

### Installation Steps

1. Download or clone the SQL script file

2. Execute the script in your MySQL environment:

```bash
mysql -u [username] -p < ecommerce_database.sql
```

The script will:
- Create a new database called `ecommerce_db`
- Build all tables with proper constraints and relationships
- Insert extensive sample data (20+ records in each major table)
- Create indexes for performance optimization

### Verification

After execution, verify the database creation and data population:

```sql
SHOW DATABASES;
USE ecommerce_db;
SHOW TABLES;

-- Check record counts in major tables
SELECT 'Users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews;
```

## Extensive Sample Data

The database includes comprehensive sample records with realistic data:

- 25 user accounts (23 customers, 2 administrators) with complete profile information
- 32 addresses linked to users across multiple regions in the United States
- 12 product categories with hierarchical structure (Electronics, Clothing, Home & Kitchen, Books, Sports)
- 28 products across different categories with detailed descriptions and pricing
- 45 product images with primary/secondary image flags and alt text
- 24 orders with various statuses (pending, processing, shipped, delivered, cancelled)
- 58 order items with quantity and price details
- 24 payment records with multiple payment methods (credit card, debit card, PayPal, bank transfer)
- 36 product reviews and ratings with detailed comments
- 32 shopping cart items across multiple users
- 28 wishlist items for various products
- 6 discount codes with different conditions and values
- 8 order-discount relationships applying promotions to specific orders

## Key Features

### Data Integrity

- Primary and foreign key constraints ensuring relational integrity
- Unique constraints on business keys (emails, SKUs, etc.)
- Check constraints for value validation (prices, quantities, ratings)
- Not null constraints on required fields
- Automated timestamps for creation and updates

### Relationships

- **One-to-Many**: Users to Orders, Categories to Products, Products to Images
- **One-to-One**: Orders to Payments
- **Many-to-Many**: Orders to Products, Users to Products (via reviews)

### Business Logic

- Inventory management with stock tracking and validation
- Complete order lifecycle with status tracking
- Payment processing workflow with multiple methods
- Comprehensive product rating and review system
- Flexible discount and promotion system with usage limits

## Advanced Query Examples

### Top Selling Products

```sql
SELECT p.product_id, p.name, SUM(oi.quantity) as total_sold, 
       SUM(oi.quantity * oi.unit_price) as total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 10;
```

### Customer Lifetime Value

```sql
SELECT u.user_id, u.username, u.email,
       COUNT(DISTINCT o.order_id) as total_orders,
       SUM(o.total_amount) as lifetime_value,
       AVG(o.total_amount) as avg_order_value
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status = 'delivered'
GROUP BY u.user_id, u.username, u.email
ORDER BY lifetime_value DESC;
```

### Monthly Sales Report

```sql
SELECT YEAR(order_date) as year, MONTH(order_date) as month,
       COUNT(*) as order_count,
       SUM(total_amount) as total_sales,
       AVG(total_amount) as avg_order_value
FROM orders
WHERE status = 'delivered'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year DESC, month DESC;
```

### Product Stock Analysis

```sql
SELECT c.name as category,
       COUNT(p.product_id) as product_count,
       SUM(p.stock_quantity) as total_stock,
       AVG(p.stock_quantity) as avg_stock,
       MIN(p.stock_quantity) as min_stock,
       SUM(CASE WHEN p.stock_quantity = 0 THEN 1 ELSE 0 END) as out_of_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY total_stock DESC;
```

## Performance Optimization

The database includes strategic indexes on frequently queried columns:

- User emails and usernames for authentication
- Product categories, SKUs, and prices for filtering
- Order statuses, dates, and user IDs for reporting
- Foreign key columns for all join operations
- Full-text indexes on product names and descriptions for search

## Maintenance Considerations

- **Backup Strategy**: Implement regular database backups with point-in-time recovery
- **Archiving**: Establish policies for archiving old orders to improve performance
- **Index Maintenance**: Periodically analyze and optimize indexes using EXPLAIN
- **Data Purging**: Establish policies for purging inactive user data after specified periods
- **Partitioning**: Consider partitioning large tables (orders, order_items) by date

## Extensibility

The schema can be extended to support additional features:

- Supplier management system with purchase orders
- Multiple warehouse inventory tracking with location management
- Advanced analytics and reporting with materialized views
- Loyalty programs with point tracking and rewards
- Return and refund processing with RMA tracking
- Subscription-based products with recurring billing

## Security Considerations

- Application should hash passwords using bcrypt or similar algorithms
- Implement proper role-based access controls at the application level
- Consider encrypting sensitive data like payment information
- Regularly update database security patches and conduct security audits
- Implement SQL injection prevention at the application layer

## Author

Created by Calvine Dasilver, Database Developer with 5+ years of experience in designing and implementing relational database systems for e-commerce platforms. Specialized in performance optimization, data integrity, and scalable database architecture.
