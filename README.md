# Room Manager System

> **Full-Stack Room Management System** with Flutter mobile app, React admin panel, and Express.js backend for managing classroom schedules, sessions, and NFC-based access control.

---

## 📋 PROJECT OVERVIEW

This is a **Room Management System** with three main components:
- **Flutter Mobile App** - For faculty and students to view schedules, book rooms, and manage sessions
- **React Admin Panel** - Web-based admin interface for managing users, rooms, and timetables
- **Express.js Backend** - RESTful API with MySQL database

---

## 🏗️ PROJECT STRUCTURE

```
APP_devporject/
│
├── backend/                    # Node.js + Express API
│   ├── src/
│   │   ├── app.js             # Express configuration
│   │   ├── server.js          # Server entry point
│   │   ├── config/
│   │   │   └── db.js          # MySQL connection pool
│   │   ├── middleware/
│   │   │   └── auth.js        # JWT verification
│   │   └── modules/
│   │       └── auth/          # Authentication module
│   │           ├── auth.routes.js
│   │           ├── auth.controller.js
│   │           └── auth.service.js
│   └── package.json
│
├── admin-panel/               # React + Vite admin interface
│   ├── src/
│   │   ├── App.jsx           # Main router
│   │   ├── main.jsx          # Entry point
│   │   ├── components/
│   │   │   ├── Layout.jsx    # Sidebar + layout wrapper
│   │   │   └── ProtectedRoute.jsx
│   │   ├── hooks/
│   │   │   └── useAuth.jsx   # Authentication context
│   │   ├── pages/
│   │   │   ├── LoginPage.jsx
│   │   │   ├── DashboardPage.jsx
│   │   │   ├── UsersPage.jsx
│   │   │   ├── RoomsPage.jsx
│   │   │   ├── TimetablePage.jsx
│   │   │   ├── SessionsPage.jsx
│   │   │   ├── ReportsPage.jsx
│   │   │   └── SettingsPage.jsx
│   │   └── services/
│   │       └── api.js        # Axios API client
│   └── package.json
│
└── lib/                       # Flutter mobile app
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── models.dart
    │   ├── mock_api.dart
    │   └── providers.dart
    └── features/
        ├── auth/
        │   └── login_page.dart
        ├── home/
        │   └── home_page.dart
        ├── rooms/
        │   ├── room_list_page.dart
        │   └── room_detail_page.dart
        ├── live_session/
        │   └── nfc_stub.dart
        ├── booking/
        │   └── booking_page.dart
        └── reports/
            └── reports_page.dart
```

---

## 🚀 GETTING STARTED

### Prerequisites
- Node.js 18+ and npm
- MySQL 8.0+
- Flutter SDK 3.0+
- PowerShell (Windows)

### 1. Database Setup
```powershell
# Login to MySQL
mysql -u root -p

# Create database and tables
source backend/schema.sql

# Verify
USE app_db;
SHOW TABLES;
```

**Database:** `app_db`  
**Tables:** users, rooms, timetables, sessions, nfc_verifications, audit_logs, settings

### 2. Backend Setup
```powershell
cd backend

# Install dependencies
npm install

# Create .env file
echo "DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Lafe@2021
DB_NAME=app_db
DB_PORT=3306
JWT_SECRET=your_secret_key" > .env

# Start dev server
npm run dev
```

Backend runs on: **http://localhost:4000**

### 3. Admin Panel Setup
```powershell
cd admin-panel

# Install dependencies
npm install

# Create .env file
echo "VITE_API_URL=http://localhost:4000/api" > .env

# Start dev server
npm run dev
```

Admin panel runs on: **http://localhost:5173**

### 4. Flutter App Setup
```powershell
# Get dependencies
flutter pub get

# Run on desired platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run                  # Connected device
```

---

## 🔐 AUTHENTICATION

### Test Accounts

| Email | Password | Role | Department | Access |
|-------|----------|------|-----------|---------|
| admin@example.com | Admin@123 | ADMIN | IT | Admin Panel + Mobile |
| test@example.com | Test@123 | FACULTY | IT | Mobile Only |

### Authentication Flow
1. User submits email/password to `/api/auth/login`
2. Backend validates credentials against MySQL
3. Password verified using bcryptjs
4. JWT token generated (expires in 1 day)
5. Token stored in localStorage (web) or secure_storage (mobile)
6. Token included in Authorization header for protected routes

---

## 📡 API DOCUMENTATION

### Base URL
```
http://localhost:4000/api
```

### Authentication Endpoints

#### **POST** `/auth/login`
Login user and receive JWT token.

**Request:**
```json
{
  "email": "admin@example.com",
  "password": "Admin@123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "ADMIN",
    "dept": "IT"
  }
}
```

#### **GET** `/auth/me`
Get current user profile (requires JWT token).

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "ADMIN",
    "dept": "IT"
  }
}
```

### Health Check

#### **GET** `/health`
Check API status.

**Response:**
```json
{
  "status": "ok"
}
```

---

## 🎨 ADMIN PANEL FEATURES

### Implemented Features ✅
- **Login Page** - Email/password authentication with error handling
- **Protected Routes** - Admin-only access guard
- **Layout System** - Sidebar navigation with 7 menu items
- **Dashboard** - Stats cards (placeholder data)
- **User Session** - Persistent login with localStorage
- **Logout** - Clear session and redirect

### Pages Status

| Page | Route | Status | Description |
|------|-------|--------|-------------|
| Login | `/login` | ✅ Complete | Authentication form |
| Dashboard | `/dashboard` | ✅ Complete | Stats overview (hardcoded) |
| Users | `/users` | 🔄 Placeholder | User management CRUD |
| Rooms | `/rooms` | 🔄 Placeholder | Room management CRUD |
| Timetable | `/timetable` | 🔄 Placeholder | Schedule management |
| Sessions | `/sessions` | 🔄 Placeholder | Live session tracking |
| Reports | `/reports` | 🔄 Placeholder | Analytics & reports |
| Settings | `/settings` | 🔄 Placeholder | System configuration |

---

## 📱 FLUTTER APP FEATURES

### Implemented Features
- User authentication with backend API
- Room browsing and details
- NFC-based session management (stub)
- Booking functionality
- Session reporting
- State management via Riverpod

### Dependencies
```yaml
flutter_riverpod: ^2.3.6      # State management
dio: ^5.0.0                   # HTTP client
go_router: ^7.0.0             # Navigation
flutter_secure_storage: ^8.0.0 # Token storage
nfc_manager: ^3.2.0           # NFC support
intl: ^0.20.2                 # Localization
uuid: ^3.0.7                  # Unique IDs
```

---

## 🗄️ DATABASE SCHEMA

### Users Table
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  role ENUM('ADMIN', 'FACULTY', 'STUDENT'),
  dept VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Rooms Table
```sql
CREATE TABLE rooms (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  type ENUM('CLASSROOM', 'LAB', 'SEMINAR'),
  department VARCHAR(100),
  capacity INT,
  status ENUM('AVAILABLE', 'OCCUPIED'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Timetables Table
```sql
CREATE TABLE timetables (
  id INT PRIMARY KEY AUTO_INCREMENT,
  room_id INT,
  faculty_id INT,
  subject VARCHAR(255),
  day_of_week VARCHAR(20),
  start_time TIME,
  end_time TIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id) REFERENCES rooms(id),
  FOREIGN KEY (faculty_id) REFERENCES users(id)
);
```

### Sessions Table
```sql
CREATE TABLE sessions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  room_id INT,
  faculty_id INT,
  start_time DATETIME,
  end_time DATETIME,
  status ENUM('ACTIVE', 'COMPLETED'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id) REFERENCES rooms(id),
  FOREIGN KEY (faculty_id) REFERENCES users(id)
);
```

---

## 🛠️ TECHNOLOGY STACK

### Backend
- **Runtime:** Node.js 18+
- **Framework:** Express.js 5.2.1
- **Database:** MySQL 8.0
- **ORM/Query:** mysql2 (promises)
- **Authentication:** JWT + bcryptjs
- **Middleware:** CORS, body-parser

### Admin Panel
- **Framework:** React 18.2.0
- **Build Tool:** Vite 5.0.8
- **Routing:** React Router v6
- **HTTP Client:** Axios 1.6.2
- **Styling:** Inline CSS (no framework)
- **Icons:** Lucide React

### Mobile App
- **Framework:** Flutter 3.0+
- **Language:** Dart 2.18+
- **State Management:** Riverpod 2.3.6
- **HTTP:** Dio 5.0.0
- **Navigation:** GoRouter 7.0.0
- **Storage:** Flutter Secure Storage

---

## 🔧 CONFIGURATION

### Backend Environment Variables
```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Lafe@2021
DB_NAME=app_db
DB_PORT=3306

# Authentication
JWT_SECRET=your_secret_key_here

# Optional: Database URL (alternative to discrete vars)
# DATABASE_URL=mysql://user:pass@host:3306/dbname
# DB_SSL=true
```

### Admin Panel Environment Variables
```env
VITE_API_URL=http://localhost:4000/api
```

---

## 📊 CURRENT STATUS

### ✅ Completed
- Backend Express.js server with MySQL connection
- Authentication system (login, JWT, password hashing)
- Admin panel React app with routing
- Protected routes with admin guard
- Login page with error handling
- Sidebar layout with navigation
- API service layer (Axios client)
- Database schema with 7 tables
- Test user accounts
- Flutter app structure with features

### 🔄 In Progress / Pending
- User management CRUD (backend routes + frontend forms)
- Room management CRUD
- Timetable management CRUD
- Live session tracking
- NFC verification system
- Reports and analytics
- Dashboard with real-time data
- Settings management

---

## 🧪 TESTING

### Test Backend Health
```powershell
curl http://localhost:4000/health
```

### Test Login
```powershell
Invoke-WebRequest -Uri "http://localhost:4000/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"admin@example.com","password":"Admin@123"}' `
  | Select-Object -ExpandProperty Content
```

### Query Database
```powershell
mysql -u root -pLafe@2021 app_db -e "SELECT id, name, email, role FROM users;"
```

---

## 📝 DEVELOPMENT NOTES

### Backend Module Pattern
Each module follows this structure:
```
modules/<feature>/
├── <feature>.routes.js      # Express routes
├── <feature>.controller.js  # Request handlers
└── <feature>.service.js     # Business logic & DB queries
```

### Frontend Page Pattern
Each page component:
1. Imports `Layout` component
2. Uses `useAuth` hook if needed
3. Fetches data via `api` service
4. Manages local state with `useState`
5. Handles loading and error states

### API Client Pattern
All API calls go through `services/api.js`:
- Centralized configuration
- Auto-inject JWT token
- Consistent error handling
- Easy to mock for testing

---

## 🚧 KNOWN ISSUES

1. **Dashboard stats are hardcoded** - Need backend endpoints to fetch real counts
2. **User/Room/Timetable pages are placeholders** - CRUD endpoints not implemented
3. **No error boundary** - App crashes on unhandled errors
4. **No loading indicators** - Poor UX during data fetching
5. **No form validation** - Client-side validation not implemented

---

## 🎯 NEXT STEPS

1. Implement backend CRUD modules for users, rooms, timetables
2. Connect admin panel forms to backend APIs
3. Add real-time data to dashboard
4. Implement session management
5. Add NFC integration
6. Build reports and analytics
7. Add proper error handling and validation
8. Implement role-based permissions
9. Add email notifications
10. Deploy to production

---

## 📄 LICENSE

This project is for educational purposes.

---

## 👥 CONTRIBUTORS

- Development Team
- Project Date: January 2026

---

## 📞 SUPPORT

For issues or questions, please contact the development team.
