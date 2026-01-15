# Admin Panel - Room Management System

Complete React + Vite admin dashboard for controlling the room management system.

## Features

✅ **Admin Login** - JWT authentication (ADMIN role only)
✅ **Dashboard** - System stats, quick actions, status indicators
✅ **User Management** - Create, edit, delete users; assign roles & departments
✅ **Room Management** - Add/edit/delete rooms; set capacity & type
✅ **Timetable Management** - Create weekly schedules, prevent clashes
✅ **Live Sessions Monitor** - Real-time table; force-end sessions (ADMIN override)
✅ **Reports & Analytics** - Most-used rooms, faculty usage, session stats
✅ **System Settings** - JWT expiry, NFC enforcement, maintenance mode

## Setup

### Prerequisites
- Node.js 16+
- Running backend API (localhost:4000)
- MySQL database with schema imported

### Installation

1. **Install dependencies:**
   ```bash
   cd admin-panel
   npm install
   ```

2. **Create `.env` file:**
   ```bash
   cp .env.example .env
   # Edit .env with your API URL
   VITE_API_URL=http://localhost:4000/api
   ```

3. **Run development server:**
   ```bash
   npm run dev
   ```
   Visit: http://localhost:5173

4. **Build for production:**
   ```bash
   npm run build
   ```

## Database Setup

1. **Import schema into MySQL:**
   ```bash
   mysql -u root -p app_db < DATABASE_SCHEMA.sql
   ```

2. **Create test admin user:**
   ```sql
   INSERT INTO users (name, email, password_hash, role, department) VALUES
   ('Admin', 'admin@example.com', bcrypt('admin123'), 'ADMIN', 'IT');
   ```
   *Note: Use bcryptjs to hash the password in your backend before inserting*

## Backend API Endpoints Required

### Auth
- `POST /api/auth/login` - Login (returns JWT)
- `GET /api/auth/me` - Get current user (requires Bearer token)

### Users
- `GET /api/users?limit=100&role=FACULTY` - List users with filters
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `POST /api/users/:id/reset-password` - Reset password

### Rooms
- `GET /api/rooms?limit=100&type=CLASSROOM` - List rooms with filters
- `POST /api/rooms` - Create room
- `PUT /api/rooms/:id` - Update room
- `DELETE /api/rooms/:id` - Delete room
- `GET /api/rooms/:id/status` - Get room current status

### Timetables
- `GET /api/timetables?limit=100` - List schedules
- `POST /api/timetables` - Create schedule
- `PUT /api/timetables/:id` - Update schedule
- `DELETE /api/timetables/:id` - Delete schedule

### Sessions (Live Classes)
- `GET /api/sessions/live` - Get all active sessions (real-time)
- `POST /api/sessions/:id/end` - Force-end a session (ADMIN only)

### Reports
- `GET /api/reports/room-usage?days=30` - Most used rooms
- `GET /api/reports/faculty-usage?days=30` - Faculty session counts
- `GET /api/reports/department-usage?days=30` - Department usage
- `GET /api/reports/session-stats?days=30` - Daily/monthly stats

### Settings
- `GET /api/settings` - Get all system settings
- `PUT /api/settings` - Update settings (ADMIN only)

## API Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

## Authentication

All endpoints (except /auth/login) require:
```
Authorization: Bearer <jwt_token>
```

Token stored in `localStorage.adminToken` on login.

## Project Structure

```
admin-panel/
├── src/
│   ├── components/
│   │   └── SidebarNav.jsx          (Navigation sidebar)
│   ├── pages/
│   │   ├── LoginPage.jsx
│   │   ├── DashboardPage.jsx
│   │   ├── UsersPage.jsx
│   │   ├── RoomsPage.jsx
│   │   ├── TimetablePage.jsx
│   │   ├── SessionsPage.jsx
│   │   ├── ReportsPage.jsx
│   │   └── SettingsPage.jsx
│   ├── services/
│   │   └── api.js                  (API layer with axios)
│   ├── hooks/
│   │   ├── useAuth.jsx             (Auth context)
│   │   └── ProtectedRoute.jsx       (Route guard)
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── public/
├── vite.config.js
├── package.json
├── .env.example
├── DATABASE_SCHEMA.sql
└── README.md
```

## Key Technologies

- **React 18** - UI library
- **Vite** - Build tool
- **React Router v6** - Routing
- **Axios** - HTTP client
- **Tailwind CSS** - Styling (via classes)
- **Lucide Icons** - Icons
- **date-fns** - Date formatting

## Security Features

✅ JWT authentication with Bearer token
✅ Admin-only access (role check on login)
✅ Protected routes (ProtectedRoute wrapper)
✅ Token stored in localStorage
✅ Auto-logout on token expiry
✅ CORS-enabled API requests
✅ Audit logs for all admin actions

## Environment Variables

```
VITE_API_URL=http://localhost:4000/api
```

## Testing

1. **Login:**
   - Email: admin@example.com
   - Password: admin123 (or your test user)

2. **Dashboard:**
   - Should display system stats
   - Quick action buttons functional

3. **User Management:**
   - Create/read/update/delete users
   - Role filtering works

4. **Sessions Monitor:**
   - Refreshes every 5 seconds
   - Force-end button works

## Deployment

### To Vercel/Netlify:
```bash
npm run build
# Deploy the dist/ folder
```

### Environment Variables (Production):
```
VITE_API_URL=https://api.yourdomain.com/api
```

## Support

For issues or API integration help, check:
- Backend repository for endpoint specifications
- MySQL schema for data structure
- API documentation

---

**Status:** Complete & Ready for Integration
**Last Updated:** January 2026
