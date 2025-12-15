-- E-commerce Database Schema

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER DEFAULT 0,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, description, price, stock, category) VALUES
    ('Laptop', 'High-performance laptop for developers', 999.99, 10, 'Electronics'),
    ('Mouse', 'Wireless ergonomic mouse', 29.99, 50, 'Accessories'),
    ('Keyboard', 'Mechanical keyboard with RGB', 79.99, 30, 'Accessories'),
    ('Monitor', '27-inch 4K display', 349.99, 15, 'Electronics'),
    ('Headphones', 'Noise-cancelling headphones', 199.99, 25, 'Audio');

-- Create index for faster queries
CREATE INDEX idx_products_category ON products(category);
