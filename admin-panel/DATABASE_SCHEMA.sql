-- Admin Panel Database Schema for Room Management System

-- Users Table (with ADMIN role support)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN', 'HOD', 'FACULTY') NOT NULL DEFAULT 'FACULTY',
  department VARCHAR(255),
  status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (email),
  INDEX (role)
);

-- Rooms Table
CREATE TABLE IF NOT EXISTS rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type ENUM('CLASSROOM', 'LAB', 'SEMINAR') NOT NULL,
  capacity INT NOT NULL,
  department VARCHAR(255),
  nfc_tag_id VARCHAR(255) UNIQUE,
  status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE') DEFAULT 'AVAILABLE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (status),
  INDEX (type)
);

-- Timetables (Weekly Schedules)
CREATE TABLE IF NOT EXISTS timetables (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_id INT NOT NULL,
  faculty_id INT NOT NULL,
  subject VARCHAR(255) NOT NULL,
  day ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (faculty_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY (room_id, day, start_time),
  INDEX (faculty_id),
  INDEX (day)
);

-- Sessions (Live Classroom Sessions)
CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_id INT NOT NULL,
  faculty_id INT NOT NULL,
  timetable_id INT,
  subject VARCHAR(255),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  nfc_verified BOOLEAN DEFAULT FALSE,
  status ENUM('ACTIVE', 'ENDED', 'NO_SHOW') DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (faculty_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (timetable_id) REFERENCES timetables(id) ON DELETE SET NULL,
  INDEX (room_id),
  INDEX (faculty_id),
  INDEX (status),
  INDEX (start_time)
);

-- NFC Verifications (Audit Trail)
CREATE TABLE IF NOT EXISTS nfc_verifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id INT,
  user_id INT NOT NULL,
  nfc_tag_id VARCHAR(255) NOT NULL,
  room_id INT NOT NULL,
  verification_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  result ENUM('SUCCESS', 'FAILED', 'UNAUTHORIZED') NOT NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  INDEX (user_id),
  INDEX (room_id),
  INDEX (verification_time)
);

-- Audit Logs (Admin Actions)
CREATE TABLE IF NOT EXISTS audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admin_id INT NOT NULL,
  action VARCHAR(255) NOT NULL,
  entity_type VARCHAR(100),
  entity_id INT,
  details JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX (admin_id),
  INDEX (created_at),
  INDEX (action)
);

-- System Settings
CREATE TABLE IF NOT EXISTS settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_name VARCHAR(100) UNIQUE NOT NULL,
  value VARCHAR(500),
  updated_by INT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert Default Settings
INSERT IGNORE INTO settings (key_name, value) VALUES
('jwt_expiry', '1d'),
('nfc_required', 'true'),
('maintenance_mode', 'false'),
('max_session_duration', '120'),
('password_policy_min_length', '8');

-- Create indexes for performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_sessions_active ON sessions(status, start_time);
CREATE INDEX idx_timetable_faculty ON timetables(faculty_id, day);
CREATE INDEX idx_nfc_room ON nfc_verifications(room_id, verification_time);
