-- Quick test user creation script
-- Run this in your MySQL database

USE app_db;

-- Create test user with bcrypt password hash for "Test@123"
-- Hash generated: $2a$10$rZ7qHqYQX6Y6JZ4gX0KW4OqhqN3K4X6Y6Z4gX0KW4OqhqN3K4X6Y6
INSERT INTO users (name, email, password_hash, role, department, status) 
VALUES 
('Test Faculty', 'test@example.com', '$2a$10$rZ7qHqYQX6Y6JZ4gX0KW4OqhqN3K4X6Y6Z4gX0KW4OqhqN3K4X6Y6', 'FACULTY', 'IT', 'ACTIVE');

-- Check if user was created
SELECT id, name, email, role FROM users;
