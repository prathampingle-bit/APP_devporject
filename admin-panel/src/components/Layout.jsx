import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

const Layout = ({ children }) => {
  const { user, logout } = useAuth();
  const location = useLocation();

  const handleLogout = () => {
    logout();
  };

  const navItems = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/users', label: 'Users', icon: '👥' },
    { path: '/rooms', label: 'Rooms', icon: '🚪' },
    { path: '/timetable', label: 'Timetable', icon: '📅' },
    { path: '/sessions', label: 'Live Sessions', icon: '⏱️' },
    { path: '/reports', label: 'Reports', icon: '📈' },
    { path: '/settings', label: 'Settings', icon: '⚙️' },
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      {/* Sidebar */}
      <div style={{
        width: '250px',
        background: '#1e293b',
        color: 'white',
        padding: '1.5rem 1rem',
        display: 'flex',
        flexDirection: 'column'
      }}>
        <div style={{ marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>Room Manager</h2>
          <p style={{ fontSize: '0.875rem', color: '#94a3b8', marginTop: '0.25rem' }}>Admin Panel</p>
        </div>

        <nav style={{ flex: 1 }}>
          {navItems.map(item => (
            <Link
              key={item.path}
              to={item.path}
              style={{
                display: 'flex',
                alignItems: 'center',
                padding: '0.75rem 1rem',
                borderRadius: '0.5rem',
                marginBottom: '0.5rem',
                background: location.pathname === item.path ? '#334155' : 'transparent',
                color: 'white',
                textDecoration: 'none',
                transition: 'background 0.2s'
              }}
            >
              <span style={{ marginRight: '0.75rem', fontSize: '1.25rem' }}>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div style={{ borderTop: '1px solid #334155', paddingTop: '1rem' }}>
          <div style={{ marginBottom: '1rem', padding: '0.5rem' }}>
            <div style={{ fontSize: '0.875rem', fontWeight: '500' }}>{user?.name}</div>
            <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{user?.email}</div>
          </div>
          <button
            onClick={handleLogout}
            style={{
              width: '100%',
              padding: '0.75rem',
              background: '#ef4444',
              color: 'white',
              border: 'none',
              borderRadius: '0.5rem',
              cursor: 'pointer',
              fontWeight: '500'
            }}
          >
            Logout
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, background: '#f5f7fa', padding: '2rem', overflowY: 'auto' }}>
        {children}
      </div>
    </div>
  );
};

export default Layout;
