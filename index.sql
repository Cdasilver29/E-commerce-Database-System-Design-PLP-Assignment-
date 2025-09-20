-- E-commerce Database Management System
-- Created by: Calvine Dasilver
-- Date: 20/9/2025

-- Create the database
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Users table (customers and administrators)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE
);

-- Addresses table (users can have multiple addresses)
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'United States',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Categories table (hierarchical categories)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT NOT NULL,
    SKU VARCHAR(100) UNIQUE NOT NULL,
    weight DECIMAL(8, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Product images table (one-to-many relationship with products)
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    shipping_address_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    tracking_number VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
);

-- Order items table (many-to-many relationship between orders and products)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments table (one-to-one relationship with orders)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(255) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Reviews table (many-to-many relationship between users and products)
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE(user_id, product_id)  -- Each user can only review a product once
);

-- Shopping cart table
CREATE TABLE cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE(user_id, product_id)  -- Each product can only appear once per user's cart
);

-- Wishlist table
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE(user_id, product_id)  -- Each product can only appear once per user's wishlist
);

-- Discounts/promotions table
CREATE TABLE discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value >= 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    max_uses INT,
    current_uses INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders discounts junction table (many-to-many relationship)
CREATE TABLE order_discounts (
    order_id INT NOT NULL,
    discount_id INT NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL CHECK (discount_amount >= 0),
    PRIMARY KEY (order_id, discount_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (discount_id) REFERENCES discounts(discount_id)
);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_cart_items_user ON cart_items(user_id);

-- Insert sample data for demonstration

-- Insert 25 users
INSERT INTO users (username, email, password_hash, first_name, last_name, phone_number, date_of_birth, is_admin) VALUES 
('admin1', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'User', '555-0101', '1980-01-01', TRUE),
('admin2', 'admin2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Second', 'Admin', '555-0102', '1985-05-15', TRUE),
('johndoe', 'john.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Doe', '555-0103', '1990-02-15', FALSE),
('janedoe', 'jane.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jane', 'Doe', '555-0104', '1992-07-22', FALSE),
('bobsmith', 'bob.smith@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bob', 'Smith', '555-0105', '1988-03-30', FALSE),
('sarajones', 'sara.jones@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sara', 'Jones', '555-0106', '1995-11-18', FALSE),
('mikejohnson', 'mike.johnson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mike', 'Johnson', '555-0107', '1987-09-05', FALSE),
('emilywilson', 'emily.wilson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Emily', 'Wilson', '555-0108', '1993-04-12', FALSE),
('davidbrown', 'david.brown@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'David', 'Brown', '555-0109', '1991-12-25', FALSE),
('lisadavis', 'lisa.davis@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Lisa', 'Davis', '555-0110', '1989-06-08', FALSE),
('kevinmiller', 'kevin.miller@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Kevin', 'Miller', '555-0111', '1994-08-14', FALSE),
('amandawilson', 'amanda.wilson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Amanda', 'Wilson', '555-0112', '1990-10-31', FALSE),
('chrisroberts', 'chris.roberts@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Chris', 'Roberts', '555-0113', '1986-01-17', FALSE),
('sophiamartinez', 'sophia.martinez@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sophia', 'Martinez', '555-0114', '1992-05-23', FALSE),
('ryanlee', 'ryan.lee@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ryan', 'Lee', '555-0115', '1988-07-07', FALSE),
('oliviaanderson', 'olivia.anderson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Olivia', 'Anderson', '555-0116', '1995-03-19', FALSE),
('jacobtaylor', 'jacob.taylor@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jacob', 'Taylor', '555-0117', '1991-09-11', FALSE),
('avawilliams', 'ava.williams@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ava', 'Williams', '555-0118', '1993-11-28', FALSE),
('noahthomas', 'noah.thomas@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Noah', 'Thomas', '555-0119', '1987-02-14', FALSE),
('isabellamoore', 'isabella.moore@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Isabella', 'Moore', '555-0120', '1994-06-30', FALSE),
('liamjackson', 'liam.jackson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Liam', 'Jackson', '555-0121', '1989-04-03', FALSE),
('miagarcia', 'mia.garcia@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mia', 'Garcia', '555-0122', '1990-08-21', FALSE),
('ethanmartin', 'ethan.martin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ethan', 'Martin', '555-0123', '1992-12-09', FALSE),
('charlottewhite', 'charlotte.white@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Charlotte', 'White', '555-0124', '1988-10-16', FALSE),
('benjaminharris', 'benjamin.harris@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Benjamin', 'Harris', '555-0125', '1995-01-27', FALSE);

-- Insert 32 addresses
INSERT INTO addresses (user_id, address_line1, address_line2, city, state, postal_code, country, is_default) VALUES 
(3, '123 Main St', 'Apt 4B', 'New York', 'NY', '10001', 'United States', TRUE),
(3, '456 Oak Ave', NULL, 'Brooklyn', 'NY', '11201', 'United States', FALSE),
(4, '789 Pine Rd', NULL, 'Los Angeles', 'CA', '90001', 'United States', TRUE),
(5, '321 Elm St', 'Suite 200', 'Chicago', 'IL', '60601', 'United States', TRUE),
(6, '654 Maple Dr', NULL, 'Houston', 'TX', '77001', 'United States', TRUE),
(7, '987 Cedar Ln', 'Apt 5C', 'Phoenix', 'AZ', '85001', 'United States', TRUE),
(8, '159 Birch Ct', NULL, 'Philadelphia', 'PA', '19101', 'United States', TRUE),
(9, '753 Spruce Way', 'Unit B', 'San Antonio', 'TX', '78201', 'United States', TRUE),
(10, '246 Willow Ave', NULL, 'San Diego', 'CA', '92101', 'United States', TRUE),
(11, '864 Palm Blvd', 'Apt 12D', 'Dallas', 'TX', '75201', 'United States', TRUE),
(12, '975 Magnolia St', NULL, 'San Jose', 'CA', '95101', 'United States', TRUE),
(13, '741 Cherry Ln', 'Suite 300', 'Austin', 'TX', '73301', 'United States', TRUE),
(14, '852 Ash Dr', NULL, 'Jacksonville', 'FL', '32201', 'United States', TRUE),
(15, '963 Poplar Rd', 'Apt 7E', 'Fort Worth', 'TX', '76101', 'United States', TRUE),
(16, '357 Oakwood Ave', NULL, 'Columbus', 'OH', '43201', 'United States', TRUE),
(17, '258 Pinecrest Dr', 'Unit 8F', 'Charlotte', 'NC', '28201', 'United States', TRUE),
(18, '369 Forest Ln', NULL, 'Indianapolis', 'IN', '46201', 'United States', TRUE),
(19, '147 Lakeview Dr', 'Apt 9G', 'Seattle', 'WA', '98101', 'United States', TRUE),
(20, '258 River Rd', NULL, 'Denver', 'CO', '80201', 'United States', TRUE),
(21, '369 Mountain View', 'Suite 400', 'Washington', 'DC', '20001', 'United States', TRUE),
(22, '741 Ocean Dr', NULL, 'Boston', 'MA', '02101', 'United States', TRUE),
(23, '852 Sunset Blvd', 'Apt 10H', 'Nashville', 'TN', '37201', 'United States', TRUE),
(24, '963 Sunrise Ave', NULL, 'Portland', 'OR', '97201', 'United States', TRUE),
(25, '157 Park Rd', 'Unit 11I', 'Las Vegas', 'NV', '89101', 'United States', TRUE),
(4, '458 Secondary St', NULL, 'San Francisco', 'CA', '94101', 'United States', FALSE),
(5, '791 Alternate Ave', 'Apt 3C', 'Miami', 'FL', '33101', 'United States', FALSE),
(6, '324 Backup Dr', NULL, 'Atlanta', 'GA', '30301', 'United States', FALSE),
(7, '657 Additional Ln', 'Suite 100', 'Detroit', 'MI', '48201', 'United States', FALSE),
(8, '988 Extra Ct', NULL, 'Minneapolis', 'MN', '55401', 'United States', FALSE),
(9, '159 Plus Way', 'Apt 6D', 'Cleveland', 'OH', '44101', 'United States', FALSE),
(10, '753 More Blvd', NULL, 'New Orleans', 'LA', '70101', 'United States', FALSE),
(11, '246 Additional St', 'Unit 7E', 'Salt Lake City', 'UT', '84101', 'United States', FALSE);

-- Insert 12 categories
INSERT INTO categories (name, description, parent_category_id) VALUES 
('Electronics', 'Electronic devices and accessories', NULL),
('Clothing', 'Fashion items for men, women and children', NULL),
('Home & Kitchen', 'Items for your home and kitchen', NULL),
('Books', 'Fiction and non-fiction books', NULL),
('Sports', 'Sports equipment and accessories', NULL),
('Smartphones', 'Mobile phones with advanced capabilities', 1),
('Laptops', 'Portable computers', 1),
('Men''s Clothing', 'Clothing for men', 2),
('Women''s Clothing', 'Clothing for women', 2),
('Cookware', 'Pots, pans, and kitchen tools', 3),
('Fiction', 'Novels and story books', 4),
('Fitness', 'Exercise equipment and accessories', 5);

-- Insert 28 products
INSERT INTO products (name, description, price, stock_quantity, category_id, SKU, weight) VALUES 
('iPhone 13 Pro', 'Latest Apple smartphone with advanced camera system', 999.99, 50, 6, 'IP13PRO-256', 0.4),
('MacBook Pro 16"', 'Powerful laptop for professionals', 2399.99, 25, 7, 'MBP16-1TB', 4.7),
('Men''s Casual Shirt', 'Comfortable cotton shirt for everyday wear', 39.99, 100, 8, 'MCS-BLUE-M', 0.5),
('Women''s Summer Dress', 'Light and breezy dress for summer', 59.99, 75, 9, 'WSD-FLORAL-S', 0.6),
('Non-Stick Frying Pan', '10-inch non-stick frying pan for everyday cooking', 29.99, 200, 10, 'NSFP-10', 1.2),
('Mystery Novel', 'Bestselling mystery thriller', 14.99, 150, 11, 'MN-1234', 0.8),
('Yoga Mat', 'High-quality yoga mat for exercise', 24.99, 80, 12, 'YM-PURPLE', 2.1),
('Samsung Galaxy S21', 'Android smartphone with excellent camera', 799.99, 45, 6, 'SGS21-128', 0.4),
('Dell XPS 13', 'Compact and powerful laptop', 1299.99, 30, 7, 'DXPS13-512', 2.8),
('Men''s Jeans', 'Classic denim jeans for men', 49.99, 120, 8, 'MJ-BLUE-32', 0.7),
('Women''s Blouse', 'Elegant blouse for formal occasions', 45.99, 90, 9, 'WB-WHITE-M', 0.4),
('Stainless Steel Pot', 'Durable 5-quart stainless steel pot', 39.99, 150, 10, 'SSP-5QT', 3.2),
('Science Fiction Book', 'Award-winning science fiction novel', 12.99, 100, 11, 'SF-5678', 0.9),
('Dumbbell Set', 'Adjustable dumbbell set for home gym', 89.99, 40, 12, 'DS-20LB', 20.0),
('Google Pixel 6', 'Google''s flagship smartphone', 699.99, 35, 6, 'GP6-128', 0.4),
('HP Spectre x360', 'Convertible laptop with touchscreen', 1399.99, 20, 7, 'HPSX360-512', 3.0),
('Men''s T-Shirt Pack', 'Pack of 3 cotton t-shirts', 29.99, 200, 8, 'MTSP-3PK', 0.6),
('Women''s Skirt', 'Flowy skirt for summer', 35.99, 85, 9, 'WS-BLACK-S', 0.4),
('Ceramic Knife Set', 'Sharp ceramic knives for kitchen', 49.99, 60, 10, 'CKS-5PC', 2.5),
('Historical Fiction', 'Engaging historical fiction novel', 13.99, 110, 11, 'HF-9012', 0.8),
('Resistance Bands', 'Set of 5 resistance bands for exercise', 19.99, 120, 12, 'RB-5SET', 1.1),
('OnePlus 9 Pro', 'High-performance Android smartphone', 899.99, 25, 6, 'OP9P-256', 0.4),
('ASUS ROG Zephyrus', 'Gaming laptop with high-end graphics', 1999.99, 15, 7, 'ARZ-1TB', 4.2),
('Men''s Formal Shirt', 'Crisp formal shirt for business occasions', 59.99, 70, 8, 'MFS-WHITE-16', 0.5),
('Women''s Winter Jacket', 'Warm jacket for cold weather', 99.99, 50, 9, 'WWJ-BLACK-M', 1.2),
('Air Fryer', 'Digital air fryer for healthy cooking', 79.99, 40, 10, 'AF-5QT', 8.5),
('Biography', 'Inspirational biography of a famous person', 15.99, 90, 11, 'BIO-3456', 0.9),
('Jump Rope', 'Adjustable speed jump rope for cardio', 12.99, 150, 12, 'JR-ADJ', 0.5);

-- Insert 45 product images
INSERT INTO product_images (product_id, image_url, alt_text, is_primary) VALUES 
(1, 'https://example.com/images/iphone13pro-1.jpg', 'iPhone 13 Pro front view', TRUE),
(1, 'https://example.com/images/iphone13pro-2.jpg', 'iPhone 13 Pro back view', FALSE),
(1, 'https://example.com/images/iphone13pro-3.jpg', 'iPhone 13 Pro side view', FALSE),
(2, 'https://example.com/images/macbookpro-1.jpg', 'MacBook Pro 16 inch', TRUE),
(2, 'https://example.com/images/macbookpro-2.jpg', 'MacBook Pro keyboard', FALSE),
(3, 'https://example.com/images/mensshirt-1.jpg', 'Men''s casual shirt blue', TRUE),
(4, 'https://example.com/images/summerdress-1.jpg', 'Women''s summer dress floral', TRUE),
(4, 'https://example.com/images/summerdress-2.jpg', 'Women''s summer dress back view', FALSE),
(5, 'https://example.com/images/fryingpan-1.jpg', 'Non-stick frying pan', TRUE),
(6, 'https://example.com/images/novel-1.jpg', 'Mystery novel cover', TRUE),
(7, 'https://example.com/images/yogamat-1.jpg', 'Yoga mat purple', TRUE),
(8, 'https://example.com/images/galaxys21-1.jpg', 'Samsung Galaxy S21', TRUE),
(8, 'https://example.com/images/galaxys21-2.jpg', 'Samsung Galaxy S21 back', FALSE),
(9, 'https://example.com/images/dellxps-1.jpg', 'Dell XPS 13', TRUE),
(9, 'https://example.com/images/dellxps-2.jpg', 'Dell XPS 13 side', FALSE),
(10, 'https://example.com/images/mensjeans-1.jpg', 'Men''s jeans blue', TRUE),
(11, 'https://example.com/images/womensblouse-1.jpg', 'Women''s blouse white', TRUE),
(12, 'https://example.com/images/stainlesspot-1.jpg', 'Stainless steel pot', TRUE),
(13, 'https://example.com/images/scifibook-1.jpg', 'Science fiction book cover', TRUE),
(14, 'https://example.com/images/dumbbells-1.jpg', 'Dumbbell set', TRUE),
(15, 'https://example.com/images/pixel6-1.jpg', 'Google Pixel 6', TRUE),
(15, 'https://example.com/images/pixel6-2.jpg', 'Google Pixel 6 back', FALSE),
(16, 'https://example.com/images/hpspectre-1.jpg', 'HP Spectre x360', TRUE),
(17, 'https://example.com/images/tshirtpack-1.jpg', 'Men''s t-shirt pack', TRUE),
(18, 'https://example.com/images/womensskirt-1.jpg', 'Women''s skirt black', TRUE),
(19, 'https://example.com/images/ceramicknives-1.jpg', 'Ceramic knife set', TRUE),
(20, 'https://example.com/images/historicalfiction-1.jpg', 'Historical fiction book cover', TRUE),
(21, 'https://example.com/images/resistancebands-1.jpg', 'Resistance bands set', TRUE),
(22, 'https://example.com/images/oneplus9pro-1.jpg', 'OnePlus 9 Pro', TRUE),
(22, 'https://example.com/images/oneplus9pro-2.jpg', 'OnePlus 9 Pro back', FALSE),
(23, 'https://example.com/images/asusrog-1.jpg', 'ASUS ROG Zephyrus', TRUE),
(23, 'https://example.com/images/asusrog-2.jpg', 'ASUS ROG Zephyrus keyboard', FALSE),
(24, 'https://example.com/images/mensformalshirt-1.jpg', 'Men''s formal shirt white', TRUE),
(25, 'https://example.com/images/winterjacket-1.jpg', 'Women''s winter jacket black', TRUE),
(25, 'https://example.com/images/winterjacket-2.jpg', 'Women''s winter jacket side', FALSE),
(26, 'https://example.com/images/airfryer-1.jpg', 'Air fryer', TRUE),
(26, 'https://example.com/images/airfryer-2.jpg', 'Air fryer control panel', FALSE),
(27, 'https://example.com/images/biography-1.jpg', 'Biography book cover', TRUE),
(28, 'https://example.com/images/jumprope-1.jpg', 'Jump rope', TRUE),
(3, 'https://example.com/images/mensshirt-2.jpg', 'Men''s casual shirt side view', FALSE),
(5, 'https://example.com/images/fryingpan-2.jpg', 'Non-stick frying pan handle', FALSE),
(7, 'https://example.com/images/yogamat-2.jpg', 'Yoga mat rolled up', FALSE),
(10, 'https://example.com/images/mensjeans-2.jpg', 'Men''s jeans back view', FALSE),
(11, 'https://example.com/images/womensblouse-2.jpg', 'Women''s blouse back view', FALSE),
(12, 'https://example.com/images/stainlesspot-2.jpg', 'Stainless steel pot with lid', FALSE),
(14, 'https://example.com/images/dumbbells-2.jpg', 'Dumbbell close-up', FALSE);

-- Insert 24 orders
INSERT INTO orders (user_id, order_date, total_amount, status, shipping_address_id, billing_address_id, tracking_number) VALUES 
(3, '2023-01-15 10:30:00', 1039.98, 'delivered', 1, 1, 'TRK123456789'),
(4, '2023-01-16 14:22:00', 2399.99, 'delivered', 3, 3, 'TRK123456790'),
(5, '2023-01-17 09:45:00', 89.98, 'delivered', 4, 4, 'TRK123456791'),
(6, '2023-01-18 16:30:00', 59.99, 'delivered', 5, 5, 'TRK123456792'),
(7, '2023-01-19 11:20:00', 29.99, 'delivered', 6, 6, 'TRK123456793'),
(8, '2023-01-20 13:15:00', 14.99, 'delivered', 7, 7, 'TRK123456794'),
(9, '2023-01-21 15:40:00', 24.99, 'delivered', 8, 8, 'TRK123456795'),
(10, '2023-01-22 12:10:00', 799.99, 'processing', 9, 9, 'TRK123456796'),
(11, '2023-01-23 10:50:00', 1299.99, 'processing', 10, 10, 'TRK123456797'),
(12, '2023-01-24 14:30:00', 95.98, 'shipped', 11, 11, 'TRK123456798'),
(13, '2023-01-25 09:25:00', 39.99, 'shipped', 12, 12, 'TRK123456799'),
(14, '2023-01-26 16:45:00', 12.99, 'pending', 13, 13, NULL),
(15, '2023-01-27 11:30:00', 89.99, 'pending', 14, 14, NULL),
(16, '2023-01-28 13:20:00', 699.99, 'pending', 15, 15, NULL),
(17, '2023-01-29 15:10:00', 1399.99, 'pending', 16, 16, NULL),
(18, '2023-01-30 10:40:00', 65.98, 'pending', 17, 17, NULL),
(19, '2023-01-31 14:15:00', 49.99, 'pending', 18, 18, NULL),
(20, '2023-02-01 12:30:00', 13.99, 'pending', 19, 19, NULL),
(21, '2023-02-02 09:50:00', 19.99, 'pending', 20, 20, NULL),
(22, '2023-02-03 16:20:00', 899.99, 'pending', 21, 21, NULL),
(23, '2023-02-04 11:45:00', 1999.99, 'pending', 22, 22, NULL),
(24, '2023-02-05 13:30:00', 59.99, 'pending', 23, 23, NULL),
(25, '2023-02-06 15:25:00', 99.99, 'pending', 24, 24, NULL),
(3, '2023-02-07 10:15:00', 79.99, 'cancelled', 1, 1, NULL);

-- Insert 58 order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 999.99),
(1, 3, 1, 39.99),
(2, 2, 1, 2399.99),
(3, 3, 2, 39.99),
(4, 4, 1, 59.99),
(5, 5, 1, 29.99),
(6, 6, 1, 14.99),
(7, 7, 1, 24.99),
(8, 8, 1, 799.99),
(9, 9, 1, 1299.99),
(10, 10, 1, 49.99),
(10, 11, 1, 45.99),
(11, 12, 1, 39.99),
(12, 13, 1, 12.99),
(13, 14, 1, 89.99),
(14, 15, 1, 699.99),
(15, 16, 1, 1399.99),
(16, 17, 2, 29.99),
(17, 18, 1, 35.99),
(17, 19, 1, 49.99),
(18, 20, 1, 13.99),
(19, 21, 1, 19.99),
(20, 22, 1, 899.99),
(21, 23, 1, 1999.99),
(22, 24, 1, 59.99),
(23, 25, 1, 99.99),
(24, 26, 1, 79.99),
(1, 7, 1, 24.99),
(2, 6, 1, 14.99),
(3, 5, 1, 29.99),
(4, 8, 1, 799.99),
(5, 9, 1, 1299.99),
(6, 10, 2, 49.99),
(7, 11, 1, 45.99),
(8, 12, 1, 39.99),
(9, 13, 1, 12.99),
(10, 14, 1, 89.99),
(11, 15, 1, 699.99),
(12, 16, 1, 1399.99),
(13, 17, 1, 29.99),
(14, 18, 1, 35.99),
(15, 19, 1, 49.99),
(16, 20, 1, 13.99),
(17, 21, 1, 19.99),
(18, 22, 1, 899.99),
(19, 23, 1, 1999.99),
(20, 24, 1, 59.99),
(21, 25, 1, 99.99),
(22, 26, 1, 79.99),
(23, 27, 1, 15.99),
(24, 28, 1, 12.99),
(1, 4, 1, 59.99),
(2, 3, 1, 39.99),
(3, 2, 1, 2399.99),
(4, 1, 1, 999.99),
(5, 2, 1, 2399.99),
(6, 3, 1, 39.99);

-- Insert 24 payments
INSERT INTO payments (order_id, payment_date, payment_method, amount, status, transaction_id) VALUES 
(1, '2023-01-15 10:31:00', 'credit_card', 1039.98, 'completed', 'TXN123456789'),
(2, '2023-01-16 14:23:00', 'paypal', 2399.99, 'completed', 'TXN123456790'),
(3, '2023-01-17 09:46:00', 'debit_card', 89.98, 'completed', 'TXN123456791'),
(4, '2023-01-18 16:31:00', 'credit_card', 59.99, 'completed', 'TXN123456792'),
(5, '2023-01-19 11:21:00', 'bank_transfer', 29.99, 'completed', 'TXN123456793'),
(6, '2023-01-20 13:16:00', 'paypal', 14.99, 'completed', 'TXN123456794'),
(7, '2023-01-21 15:41:00', 'credit_card', 24.99, 'completed', 'TXN123456795'),
(8, '2023-01-22 12:11:00', 'debit_card', 799.99, 'completed', 'TXN123456796'),
(9, '2023-01-23 10:51:00', 'credit_card', 1299.99, 'completed', 'TXN123456797'),
(10, '2023-01-24 14:31:00', 'paypal', 95.98, 'completed', 'TXN123456798'),
(11, '2023-01-25 09:26:00', 'bank_transfer', 39.99, 'completed', 'TXN123456799'),
(12, '2023-01-26 16:46:00', 'credit_card', 12.99, 'pending', 'TXN123456800'),
(13, '2023-01-27 11:31:00', 'debit_card', 89.99, 'pending', 'TXN123456801'),
(14, '2023-01-28 13:21:00', 'paypal', 699.99, 'pending', 'TXN123456802'),
(15, '2023-01-29 15:11:00', 'credit_card', 1399.99, 'pending', 'TXN123456803'),
(16, '2023-01-30 10:41:00', 'debit_card', 65.98, 'pending', 'TXN123456804'),
(17, '2023-01-31 14:16:00', 'paypal', 49.99, 'pending', 'TXN123456805'),
(18, '2023-02-01 12:31:00', 'credit_card', 13.99, 'pending', 'TXN123456806'),
(19, '2023-02-02 09:51:00', 'bank_transfer', 19.99, 'pending', 'TXN123456807'),
(20, '2023-02-03 16:21:00', 'credit_card', 899.99, 'pending', 'TXN123456808'),
(21, '2023-02-04 11:46:00', 'paypal', 1999.99, 'pending', 'TXN123456809'),
(22, '2023-02-05 13:31:00', 'debit_card', 59.99, 'pending', 'TXN123456810'),
(23, '2023-02-06 15:26:00', 'credit_card', 99.99, 'pending', 'TXN123456811'),
(24, '2023-02-07 10:16:00', 'paypal', 79.99, 'refunded', 'TXN123456812');

-- Insert 36 reviews
INSERT INTO reviews (user_id, product_id, rating, title, comment) VALUES 
(3, 1, 5, 'Excellent phone!', 'The camera quality is amazing and battery life lasts all day.'),
(3, 3, 4, 'Comfortable shirt', 'Fits well and is very comfortable for daily wear.'),
(4, 2, 5, 'Powerful laptop', 'Handles all my professional work without any issues.'),
(5, 3, 4, 'Good quality', 'Nice shirt for the price, would buy again.'),
(6, 4, 5, 'Beautiful dress', 'Perfect for summer, received many compliments.'),
(7, 5, 4, 'Non-stick works well', 'Even heating and easy to clean.'),
(8, 6, 5, 'Page turner!', 'Could not put this book down, highly recommend.'),
(9, 7, 4, 'Good yoga mat', 'Comfortable and provides good grip during exercises.'),
(10, 8, 5, 'Great Android phone', 'Smooth performance and excellent camera.'),
(11, 9, 4, 'Solid laptop', 'Good performance and battery life.'),
(12, 10, 5, 'Perfect fit', 'True to size and comfortable jeans.'),
(12, 11, 4, 'Nice blouse', 'Good material and looks elegant.'),
(13, 12, 5, 'Durable pot', 'Heats evenly and cleans easily.'),
(14, 13, 4, 'Engaging read', 'Interesting concepts and well-written.'),
(15, 14, 5, 'Versatile weights', 'Perfect for home workouts with limited space.'),
(16, 15, 4, 'Clean Android experience', 'No bloatware and regular updates.'),
(17, 16, 5, 'Great convertible', 'Touchscreen is responsive and design is sleek.'),
(18, 17, 4, 'Good value', 'Comfortable t-shirts at a reasonable price.'),
(19, 18, 5, 'Flowy and comfortable', 'Perfect for hot summer days.'),
(20, 19, 4, 'Sharp knives', 'Stay sharp and are easy to handle.'),
(21, 20, 5, 'Historical masterpiece', 'Well-researched and engaging story.'),
(22, 21, 4, 'Good resistance bands', 'Various resistance levels for different exercises.'),
(23, 22, 5, 'Fast and smooth', 'Excellent performance and charging speed.'),
(24, 23, 4, 'Gaming beast', 'Handles all AAA games at high settings.'),
(25, 24, 5, 'Professional look', 'Great for business meetings and formal events.'),
(3, 7, 4, 'Comfortable mat', 'Good thickness for various exercises.'),
(4, 6, 5, 'Mystery solved!', 'Great plot twists and character development.'),
(5, 5, 4, 'Even heating', 'Cookes food evenly without hot spots.'),
(6, 8, 5, 'Excellent camera', 'Takes amazing photos in low light.'),
(7, 9, 4, 'Reliable performance', 'Good for work and entertainment.'),
(8, 10, 5, 'Comfortable jeans', 'True to size and doesn''t shrink.'),
(9, 11, 4, 'Elegant blouse', 'Good for office wear.'),
(10, 12, 5, 'Quality cookware', 'Will last for years.'),
(11, 13, 4, 'Thought-provoking', 'Makes you think about future possibilities.'),
(12, 14, 5, 'Space efficient', 'Great for small apartments.');

-- Insert 32 cart items
INSERT INTO cart_items (user_id, product_id, quantity) VALUES 
(3, 2, 1),
(3, 6, 2),
(4, 4, 1),
(5, 5, 1),
(6, 8, 1),
(7, 9, 1),
(8, 10, 2),
(9, 11, 1),
(10, 12, 1),
(11, 13, 1),
(12, 14, 1),
(13, 15, 1),
(14, 16, 1),
(15, 17, 2),
(16, 18, 1),
(17, 19, 1),
(18, 20, 1),
(19, 21, 1),
(20, 22, 1),
(21, 23, 1),
(22, 24, 1),
(23, 25, 1),
(24, 26, 1),
(25, 27, 1),
(3, 28, 2),
(4, 1, 1),
(5, 2, 1),
(6, 3, 2),
(7, 4, 1),
(8, 5, 1),
(9, 6, 2),
(10, 7, 1);

-- Insert 28 wishlist items
INSERT INTO wishlist (user_id, product_id) VALUES 
(3, 2),
(3, 15),
(4, 1),
(5, 3),
(6, 4),
(7, 5),
(8, 6),
(9, 7),
(10, 8),
(11, 9),
(12, 10),
(13, 11),
(14, 12),
(15, 13),
(16, 14),
(17, 15),
(18, 16),
(19, 17),
(20, 18),
(21, 19),
(22, 20),
(23, 21),
(24, 22),
(25, 23),
(3, 24),
(4, 25),
(5, 26),
(6, 27);

-- Insert 6 discounts
INSERT INTO discounts (code, description, discount_type, discount_value, min_order_amount, start_date, end_date, max_uses, current_uses, is_active) VALUES 
('WELCOME10', '10% off for new customers', 'percentage', 10.00, 50.00, '2023-01-01 00:00:00', '2023-12-31 23:59:59', 1000, 25, TRUE),
('FREESHIP', 'Free shipping on orders over $75', 'fixed_amount', 9.99, 75.00, '2023-01-01 00:00:00', '2023-12-31 23:59:59', 5000, 12, TRUE),
('SUMMER25', '25% off summer collection', 'percentage', 25.00, 100.00, '2023-06-01 00:00:00', '2023-08-31 23:59:59', 500, 3, TRUE),
('TECH20', '20% off electronics', 'percentage', 20.00, 200.00, '2023-03-01 00:00:00', '2023-03-31 23:59:59', 200, 8, FALSE),
('SAVE15', '$15 off orders over $100', 'fixed_amount', 15.00, 100.00, '2023-02-01 00:00:00', '2023-02-28 23:59:59', 300, 15, FALSE),
('BOOKLOVER', '10% off all books', 'percentage', 10.00, 25.00, '2023-01-01 00:00:00', '2023-12-31 23:59:59', 1000, 7, TRUE);

-- Insert 8 order discounts
INSERT INTO order_discounts (order_id, discount_id, discount_amount) VALUES 
(1, 1, 103.99),
(3, 1, 8.99),
(4, 2, 9.99),
(10, 1, 9.59),
(10, 6, 1.44),
(12, 6, 1.29),
(16, 1, 6.59),
(18, 6, 1.39);

-- Display confirmation message
SELECT 'E-commerce database schema created successfully with extensive sample data!' AS Status;
