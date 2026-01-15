import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { createRoom, deleteRoom, getRooms, updateRoom } from '../services/rooms';

const statusColors = {
  AVAILABLE: { bg: '#ecfdf3', fg: '#166534', label: 'Available' },
  IN_USE: { bg: '#fef9c3', fg: '#854d0e', label: 'In use' },
  MAINTENANCE: { bg: '#fee2e2', fg: '#991b1b', label: 'Maintenance' },
};

const emptyRoom = {
  name: '',
  code: '',
  capacity: '',
  status: 'AVAILABLE',
};

const RoomsPage = () => {
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [form, setForm] = useState(emptyRoom);
  const [createOpen, setCreateOpen] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [selectedRoom, setSelectedRoom] = useState(null);
  const [saving, setSaving] = useState(false);

  const loadRooms = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await getRooms();
      setRooms(Array.isArray(data) ? data : data?.rooms || []);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to fetch rooms');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRooms();
  }, []);

  const submitCreate = async () => {
    setSaving(true);
    setError('');
    try {
      await createRoom({ ...form, capacity: Number(form.capacity) || 0 });
      setCreateOpen(false);
      setForm(emptyRoom);
      await loadRooms();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Create failed');
    } finally {
      setSaving(false);
    }
  };

  const submitEdit = async () => {
    if (!selectedRoom) return;
    setSaving(true);
    setError('');
    try {
      await updateRoom(selectedRoom.id, { ...form, capacity: Number(form.capacity) || 0 });
      setEditOpen(false);
      setSelectedRoom(null);
      setForm(emptyRoom);
      await loadRooms();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Update failed');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (room) => {
    if (!window.confirm(`Delete room ${room.name}?`)) return;
    setSaving(true);
    setError('');
    try {
      await deleteRoom(room.id);
      await loadRooms();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Delete failed');
    } finally {
      setSaving(false);
    }
  };

  const openEdit = (room) => {
    setSelectedRoom(room);
    setForm({
      name: room.name || '',
      code: room.code || '',
      capacity: room.capacity ?? '',
      status: room.status || 'AVAILABLE',
    });
    setEditOpen(true);
  };

  return (
    <Layout>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Rooms</h1>
          <p style={{ color: '#475569', marginTop: '0.35rem' }}>Manage physical rooms and keep Flutter clients in sync.</p>
        </div>
        <button
          onClick={() => setCreateOpen(true)}
          style={{
            padding: '0.75rem 1.25rem',
            borderRadius: '0.75rem',
            background: '#0ea5e9',
            color: 'white',
            border: 'none',
            cursor: 'pointer',
            fontWeight: 600,
            boxShadow: '0 10px 30px rgba(14,165,233,0.3)'
          }}
        >
          + Add Room
        </button>
      </div>

      {error && (
        <div style={{ marginBottom: '1rem', padding: '1rem', background: '#fef2f2', color: '#b91c1c', border: '1px solid #fecdd3', borderRadius: '0.75rem' }}>
          {error}
        </div>
      )}

      <div style={{ background: 'white', borderRadius: '1rem', border: '1px solid #e2e8f0', boxShadow: '0 10px 40px rgba(15,23,42,0.08)', overflow: 'hidden' }}>
        <div style={{ padding: '1rem', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#475569', fontWeight: 600 }}>All Rooms</span>
          {loading && <span style={{ color: '#94a3b8' }}>Loading...</span>}
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ background: '#f8fafc' }}>
              <tr>
                {['Name', 'Code', 'Capacity', 'Status', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '0.75rem 1rem', fontSize: '0.9rem', color: '#475569', borderBottom: '1px solid #e2e8f0' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!loading && rooms.length === 0 && (
                <tr>
                  <td colSpan={5} style={{ padding: '1.5rem', textAlign: 'center', color: '#94a3b8' }}>No rooms found.</td>
                </tr>
              )}
              {rooms.map((room) => {
                const badge = statusColors[room.status] || statusColors.AVAILABLE;
                return (
                  <tr key={room.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                    <td style={{ padding: '0.9rem 1rem', fontWeight: 600, color: '#0f172a' }}>{room.name}</td>
                    <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{room.code}</td>
                    <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{room.capacity}</td>
                    <td style={{ padding: '0.9rem 1rem' }}>
                      <span style={{ padding: '0.35rem 0.65rem', borderRadius: '999px', background: badge.bg, color: badge.fg, fontWeight: 700, fontSize: '0.85rem' }}>
                        {badge.label}
                      </span>
                    </td>
                    <td style={{ padding: '0.9rem 1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                      <button onClick={() => openEdit(room)} style={{ border: '1px solid #e2e8f0', background: 'white', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }}>Edit</button>
                      <button onClick={() => handleDelete(room)} style={{ border: 'none', background: '#fee2e2', color: '#b91c1c', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }} disabled={saving}>Delete</button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {(createOpen || editOpen) && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(15,23,42,0.45)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '1rem', zIndex: 1000 }}>
          <div style={{ width: '100%', maxWidth: '480px', background: 'white', borderRadius: '1rem', padding: '1.5rem', boxShadow: '0 25px 70px rgba(15,23,42,0.25)', border: '1px solid #e2e8f0' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <h2 style={{ fontSize: '1.25rem', fontWeight: 700 }}>{createOpen ? 'Add room' : `Edit ${selectedRoom?.name || ''}`}</h2>
              <button onClick={() => { setCreateOpen(false); setEditOpen(false); }} style={{ background: 'transparent', border: 'none', fontSize: '1.25rem', cursor: 'pointer' }}>×</button>
            </div>
            <div style={{ display: 'grid', gap: '1rem' }}>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Name</label>
                <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="Room name" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
              </div>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Code</label>
                <input value={form.code} onChange={(e) => setForm({ ...form, code: e.target.value })} placeholder="RM-101" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Capacity</label>
                  <input value={form.capacity} type="number" onChange={(e) => setForm({ ...form, capacity: e.target.value })} placeholder="40" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
                </div>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Status</label>
                  <select value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })} style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem', background: 'white' }}>
                    <option value="AVAILABLE">Available</option>
                    <option value="IN_USE">In use</option>
                    <option value="MAINTENANCE">Maintenance</option>
                  </select>
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
                <button onClick={() => { setCreateOpen(false); setEditOpen(false); }} style={{ padding: '0.75rem 1.1rem', borderRadius: '0.65rem', border: '1px solid #e2e8f0', background: 'white', cursor: 'pointer' }}>Cancel</button>
                <button
                  onClick={createOpen ? submitCreate : submitEdit}
                  disabled={saving}
                  style={{ padding: '0.75rem 1.25rem', borderRadius: '0.65rem', border: 'none', background: '#0ea5e9', color: 'white', cursor: saving ? 'not-allowed' : 'pointer' }}
                >
                  {saving ? 'Saving...' : (createOpen ? 'Create' : 'Save changes')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
};

export default RoomsPage;
