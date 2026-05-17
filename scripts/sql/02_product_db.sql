-- =============================================================================
-- PRODUCT DATABASE INITIALIZATION SCRIPT
-- Database: product_db
-- Description: Creates tables for product catalog and inventory management
-- =============================================================================

CREATE DATABASE IF NOT EXISTS product_db;
USE product_db;

-- -----------------------------------------------------------------------------
-- CATEGORIES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    image_url VARCHAR(500),
    parent_id BIGINT NULL,
    active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- PRODUCTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    image_url VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    sale_price DECIMAL(10, 2),
    sku VARCHAR(100) UNIQUE,
    category_id BIGINT,
    brand VARCHAR(100),
    stock_quantity INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    active BOOLEAN DEFAULT TRUE,
    featured BOOLEAN DEFAULT FALSE,
    weight DECIMAL(10, 3),
    dimensions VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- PRODUCT VARIANTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_variants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku VARCHAR(100) UNIQUE,
    name VARCHAR(200),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock_quantity INT DEFAULT 0,
    attributes JSON,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- PRODUCT IMAGES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- INDEXES FOR PERFORMANCE
-- -----------------------------------------------------------------------------
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(active);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_product_variants_product ON product_variants(product_id);
CREATE INDEX idx_product_variants_sku ON product_variants(sku);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_product_images_product ON product_images(product_id);

-- -----------------------------------------------------------------------------
-- SEED DATA: SAMPLE CATEGORIES
-- -----------------------------------------------------------------------------
INSERT INTO categories (name, description, display_order) VALUES 
    ('Electronics', 'Electronic devices and accessories', 1),
    ('Clothing', 'Apparel and fashion items', 2),
    ('Home & Garden', 'Home improvement and garden supplies', 3),
    ('Books', 'Books and publications', 4)
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- -----------------------------------------------------------------------------
-- SEED DATA: SAMPLE PRODUCTS
-- -----------------------------------------------------------------------------
INSERT INTO products (name, description, price, sku, category_id, stock_quantity, active, featured) VALUES 
    ('Wireless Headphones', 'High-quality Bluetooth wireless headphones with noise cancellation', 199.99, 'ELEC-WH-001', 1, 50, TRUE, TRUE),
    ('Smart Watch', 'Feature-rich smartwatch with health monitoring', 299.99, 'ELEC-SW-001', 1, 30, TRUE, TRUE),
    ('Laptop Stand', 'Ergonomic aluminum laptop stand', 49.99, 'ELEC-LS-001', 1, 100, TRUE, FALSE),
    ('Cotton T-Shirt', 'Premium cotton t-shirt available in multiple colors', 29.99, 'CLOTH-TS-001', 2, 200, TRUE, FALSE),
    ('Denim Jeans', 'Classic fit denim jeans', 59.99, 'CLOTH-DJ-001', 2, 75, TRUE, TRUE),
    ('Garden Tool Set', 'Complete garden tool set with carrying case', 89.99, 'HOME-GT-001', 3, 40, TRUE, FALSE),
    ('Programming Guide', 'Comprehensive programming guide for beginners', 39.99, 'BOOK-PG-001', 4, 60, TRUE, FALSE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- -----------------------------------------------------------------------------
-- SEED DATA: SAMPLE PRODUCT VARIANTS
-- -----------------------------------------------------------------------------
INSERT INTO product_variants (product_id, sku, name, price, stock_quantity, attributes) VALUES 
    (1, 'ELEC-WH-001-BLK', 'Wireless Headphones - Black', 199.99, 25, '{"color": "Black"}'),
    (1, 'ELEC-WH-001-WHT', 'Wireless Headphones - White', 199.99, 25, '{"color": "White"}'),
    (2, 'ELEC-SW-001-SLV', 'Smart Watch - Silver', 299.99, 15, '{"color": "Silver", "size": "42mm"}'),
    (2, 'ELEC-SW-001-BLK', 'Smart Watch - Black', 299.99, 15, '{"color": "Black", "size": "42mm"}'),
    (4, 'CLOTH-TS-001-S', 'Cotton T-Shirt - Small', 29.99, 50, '{"size": "S", "color": "White"}'),
    (4, 'CLOTH-TS-001-M', 'Cotton T-Shirt - Medium', 29.99, 70, '{"size": "M", "color": "White"}'),
    (4, 'CLOTH-TS-001-L', 'Cotton T-Shirt - Large', 29.99, 80, '{"size": "L", "color": "White"}')
ON DUPLICATE KEY UPDATE name = VALUES(name);

SELECT 'Product database initialized successfully!' AS message;