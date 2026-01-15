import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { getStats } from '../services/stats';
import { useNavigate } from 'react-router-dom';

const cards = [
  { key: 'totalUsers', label: 'Total Users', icon: '👥', color: '#2563eb' },
  { key: 'totalRooms', label: 'Total Rooms', icon: '🚪', color: '#14b8a6' },
  { key: 'activeSessions', label: 'Active Sessions', icon: '⏱️', color: '#f59e0b' },
  { key: 'todaysBookings', label: "Today's Bookings", icon: '📅', color: '#8b5cf6' },
  { key: 'totalAdmins', label: 'Admins / HOD', icon: '🛡️', color: '#ef4444' },
];

const DashboardPage = () => {
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const loadStats = async () => {
    setError('');
    try {
      const data = await getStats();
      setStats(data || {});
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to load stats');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStats();
  }, []);

  return (
    <Layout>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Dashboard</h1>
          <p style={{ color: '#475569', marginTop: '0.35rem' }}>Live overview of the facility and sessions.</p>
        </div>
        {loading && <span style={{ color: '#94a3b8' }}>Loading...</span>}
      </div>

      {error && (
        <div style={{ marginBottom: '1rem', padding: '1rem', background: '#fef2f2', color: '#b91c1c', border: '1px solid #fecdd3', borderRadius: '0.75rem' }}>
          {error}
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
        {cards.map((card) => (
          <div key={card.key} style={{ background: 'white', padding: '1.5rem', borderRadius: '1rem', boxShadow: '0 12px 35px rgba(15,23,42,0.08)', border: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: '2rem', marginBottom: '0.35rem' }}>{card.icon}</div>
              <div style={{ color: '#475569', fontSize: '0.9rem', marginBottom: '0.25rem' }}>{card.label}</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#0f172a' }}>{stats[card.key] ?? 0}</div>
            </div>
            <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: `${card.color}22`, display: 'grid', placeItems: 'center', color: card.color, fontWeight: 800 }}>
              •
            </div>
          </div>
        ))}
      </div>

      <div style={{ background: 'white', padding: '1.5rem', borderRadius: '1rem', boxShadow: '0 12px 35px rgba(15,23,42,0.08)', border: '1px solid #e2e8f0' }}>
        <h2 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginBottom: '1rem' }}>
          Quick Actions
        </h2>
        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
          <button onClick={() => navigate('/users')} style={{ padding: '0.75rem 1.5rem', background: '#2563eb', color: 'white', border: 'none', borderRadius: '0.75rem', cursor: 'pointer', fontWeight: '600' }}>
            Add User
          </button>
          <button onClick={() => navigate('/rooms')} style={{ padding: '0.75rem 1.5rem', background: '#14b8a6', color: 'white', border: 'none', borderRadius: '0.75rem', cursor: 'pointer', fontWeight: '600' }}>
            Add Room
          </button>
          <button onClick={() => navigate('/sessions')} style={{ padding: '0.75rem 1.5rem', background: '#f59e0b', color: 'white', border: 'none', borderRadius: '0.75rem', cursor: 'pointer', fontWeight: '600' }}>
            Monitor Sessions
          </button>
          <button onClick={() => navigate('/timetable')} style={{ padding: '0.75rem 1.5rem', background: '#8b5cf6', color: 'white', border: 'none', borderRadius: '0.75rem', cursor: 'pointer', fontWeight: '600' }}>
            Build Timetable
          </button>
        </div>
      </div>
    </Layout>
  );
};

export default DashboardPage;
