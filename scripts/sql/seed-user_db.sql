-- =============================================================================
-- USER DATABASE SEED DATA
-- Description: Inserts seed data for user authentication and roles
-- Note: Tables must exist (created by Hibernate or 01_user_db.sql)
-- =============================================================================

USE user_db;

-- -----------------------------------------------------------------------------
-- SEED DATA: ROLES
-- Note: The existing schema uses enum('ADMINISTRATOR','CUSTOMER','EMPLOYEE')
-- -----------------------------------------------------------------------------
INSERT INTO roles (name) VALUES 
    ('ADMINISTRATOR'),
    ('EMPLOYEE'),
    ('CUSTOMER')
ON DUPLICATE KEY UPDATE name = name;

-- -----------------------------------------------------------------------------
-- SEED DATA: DEFAULT USERS
-- Password: admin123 -> BCrypt hashed
-- Password: customer123 -> BCrypt hashed
-- Password: employee123 -> BCrypt hashed
-- -----------------------------------------------------------------------------
INSERT INTO users (username, email, password, first_name, last_name, enabled, non_locked) VALUES 
    ('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'System', 'Administrator', 1, 1),
    ('customer1', 'customer@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'John', 'Customer', 1, 1),
    ('employee1', 'employee@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'Jane', 'Employee', 1, 1)
ON DUPLICATE KEY UPDATE username = username;

-- -----------------------------------------------------------------------------
-- ASSIGN ROLES TO USERS
-- -----------------------------------------------------------------------------
-- Get IDs and insert into user_roles
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.username = 'admin' AND r.name = 'ADMINISTRATOR'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.username = 'customer1' AND r.name = 'CUSTOMER'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.username = 'employee1' AND r.name = 'EMPLOYEE'
ON DUPLICATE KEY UPDATE user_id = user_id;

-- -----------------------------------------------------------------------------
-- VERIFICATION
-- -----------------------------------------------------------------------------
SELECT 'Roles:' AS '';
SELECT * FROM roles;

SELECT 'Users:' AS '';
SELECT id, username, email, first_name, last_name, enabled FROM users;

SELECT 'User-Role Assignments:' AS '';
SELECT u.username, r.name as role FROM users u 
JOIN user_roles ur ON u.id = ur.user_id 
JOIN roles r ON ur.role_id = r.id;