import React from 'react';
import { useNavigate } from 'react-router-dom';

const AccessDeniedPage = () => {
  const navigate = useNavigate();

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#0f172a',
      color: 'white',
      padding: '2rem'
    }}>
      <div style={{
        maxWidth: '480px',
        width: '100%',
        background: '#111827',
        borderRadius: '1rem',
        padding: '2rem',
        boxShadow: '0 20px 50px rgba(0,0,0,0.45)',
        border: '1px solid #1f2937'
      }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⛔</div>
        <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>
          Access Denied
        </h1>
        <p style={{ color: '#cbd5e1', marginBottom: '1.5rem' }}>
          Your account does not have permission to access this admin panel. Please contact an administrator if you believe this is an error.
        </p>
        <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
          <button
            onClick={() => navigate('/login')}
            style={{
              padding: '0.75rem 1.25rem',
              borderRadius: '0.75rem',
              border: '1px solid #334155',
              background: 'transparent',
              color: 'white',
              cursor: 'pointer'
            }}
          >
            Back to login
          </button>
          <button
            onClick={() => navigate(-1)}
            style={{
              padding: '0.75rem 1.25rem',
              borderRadius: '0.75rem',
              border: 'none',
              background: '#f43f5e',
              color: 'white',
              cursor: 'pointer'
            }}
          >
            Go back
          </button>
        </div>
      </div>
    </div>
  );
};

export default AccessDeniedPage;
