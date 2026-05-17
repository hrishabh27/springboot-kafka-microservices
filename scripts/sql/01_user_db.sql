-- =============================================================================
-- USER DATABASE INITIALIZATION SCRIPT
-- Database: user_db
-- Description: Creates tables for user authentication and authorization
-- =============================================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS user_db;
USE user_db;

-- -----------------------------------------------------------------------------
-- ROLES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- USERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    enabled BOOLEAN DEFAULT TRUE,
    non_locked BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- USER_ROLES JOIN TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- INDEXES FOR PERFORMANCE
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_enabled ON users(enabled);
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- -----------------------------------------------------------------------------
-- SEED DATA: DEFAULT ROLES
-- -----------------------------------------------------------------------------
INSERT INTO roles (name, description) VALUES 
    ('ROLE_ADMIN', 'System Administrator with full access'),
    ('ROLE_EMPLOYEE', 'Employee with limited management access'),
    ('ROLE_CUSTOMER', 'Customer with shopping privileges')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- -----------------------------------------------------------------------------
-- SEED DATA: DEFAULT ADMIN USER
-- Password: admin123 (BCrypt hashed)
-- -----------------------------------------------------------------------------
INSERT INTO users (username, email, password, first_name, last_name, enabled, non_locked)
VALUES ('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'System', 'Administrator', TRUE, TRUE)
ON DUPLICATE KEY UPDATE password = VALUES(password);

-- Assign ADMIN role to admin user
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN'
ON DUPLICATE KEY UPDATE user_id = user_id;

-- -----------------------------------------------------------------------------
-- VERIFICATION QUERIES
-- -----------------------------------------------------------------------------
SELECT 'Roles created:' AS message;
SELECT * FROM roles;

SELECT 'Admin user created:' AS message;
SELECT id, username, email, enabled, non_locked FROM users WHERE username = 'admin';