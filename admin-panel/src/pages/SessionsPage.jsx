import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { endSession, getActiveSessions } from '../services/sessions';

const SessionsPage = () => {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [endingId, setEndingId] = useState(null);

  const loadSessions = async () => {
    setError('');
    try {
      const data = await getActiveSessions();
      setSessions(Array.isArray(data) ? data : data?.sessions || []);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to load sessions');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSessions();
    const id = setInterval(loadSessions, 10000);
    return () => clearInterval(id);
  }, []);

  const handleEnd = async (session) => {
    if (!window.confirm('Force end this session?')) return;
    setEndingId(session.id);
    setError('');
    try {
      await endSession(session.id);
      await loadSessions();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to end session');
    } finally {
      setEndingId(null);
    }
  };

  return (
    <Layout>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Live Sessions</h1>
          <p style={{ color: '#475569', marginTop: '0.35rem' }}>Monitor active sessions and force stop if required.</p>
        </div>
        {loading && <span style={{ color: '#94a3b8' }}>Refreshing...</span>}
      </div>

      {error && (
        <div style={{ marginBottom: '1rem', padding: '1rem', background: '#fef2f2', color: '#b91c1c', border: '1px solid #fecdd3', borderRadius: '0.75rem' }}>
          {error}
        </div>
      )}

      <div style={{ background: 'white', borderRadius: '1rem', border: '1px solid #e2e8f0', boxShadow: '0 10px 40px rgba(15,23,42,0.08)' }}>
        <div style={{ padding: '1rem', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#475569', fontWeight: 600 }}>Active now</span>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ background: '#f8fafc' }}>
              <tr>
                {['Course', 'Room', 'Teacher', 'Started', 'Status', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '0.75rem 1rem', fontSize: '0.9rem', color: '#475569', borderBottom: '1px solid #e2e8f0' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!loading && sessions.length === 0 && (
                <tr>
                  <td colSpan={6} style={{ padding: '1.5rem', textAlign: 'center', color: '#94a3b8' }}>No active sessions.</td>
                </tr>
              )}
              {sessions.map((session) => (
                <tr key={session.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '0.9rem 1rem', fontWeight: 600, color: '#0f172a' }}>{session.course}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{session.room}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{session.teacher}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{session.startedAt}</td>
                  <td style={{ padding: '0.9rem 1rem' }}>
                    <span style={{ padding: '0.35rem 0.65rem', borderRadius: '999px', background: '#ecfdf3', color: '#166534', fontWeight: 700, fontSize: '0.85rem' }}>Live</span>
                  </td>
                  <td style={{ padding: '0.9rem 1rem' }}>
                    <button
                      onClick={() => handleEnd(session)}
                      disabled={endingId === session.id}
                      style={{ border: 'none', background: '#fee2e2', color: '#b91c1c', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: endingId === session.id ? 'not-allowed' : 'pointer' }}
                    >
                      {endingId === session.id ? 'Ending...' : 'End session'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default SessionsPage;
