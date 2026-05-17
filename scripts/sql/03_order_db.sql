-- =============================================================================
-- ORDER DATABASE INITIALIZATION SCRIPT
-- Database: order_db
-- Description: Creates tables for order management and fulfillment
-- =============================================================================

CREATE DATABASE IF NOT EXISTS order_db;
USE order_db;

-- -----------------------------------------------------------------------------
-- ORDERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    shipping_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    shipping_phone VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_created (created_at),
    INDEX idx_orders_number (order_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- ORDER ITEMS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- ORDER STATUS HISTORY TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_status_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_status_history_order (order_id),
    INDEX idx_status_history_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- PAYMENT DATABASE INITIALIZATION SCRIPT
-- Database: payment_db
-- Description: Creates tables for payment processing and invoices
-- =============================================================================

CREATE DATABASE IF NOT EXISTS payment_db;
USE payment_db;

-- -----------------------------------------------------------------------------
-- PAYMENTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id VARCHAR(100) UNIQUE NOT NULL,
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    transaction_id VARCHAR(255),
    gateway_response TEXT,
    payer_email VARCHAR(255),
    payer_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    INDEX idx_payments_order (order_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_transaction (transaction_id),
    INDEX idx_payments_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- INVOICES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    order_id BIGINT NOT NULL,
    payment_id BIGINT,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    billing_address TEXT,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'DRAFT',
    issued_date DATE,
    due_date DATE,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_invoices_order (order_id),
    INDEX idx_invoices_number (invoice_number),
    INDEX idx_invoices_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- REFUNDS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS refunds (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    refund_id VARCHAR(100) UNIQUE NOT NULL,
    payment_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'PENDING',
    transaction_id VARCHAR(255),
    processed_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    INDEX idx_refunds_payment (payment_id),
    INDEX idx_refunds_order (order_id),
    INDEX idx_refunds_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Order and Payment databases initialized successfully!' AS message;