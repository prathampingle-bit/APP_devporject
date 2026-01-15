import React, { useEffect, useMemo, useState } from 'react';
import Layout from '../components/Layout';
import { createTimetable, deleteTimetable, getTimetables, updateTimetable } from '../services/timetables';

const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const emptySlot = {
  course: '',
  teacher: '',
  room: '',
  day: 'Monday',
  startTime: '09:00',
  endTime: '10:00',
};

const TimetablePage = () => {
  const [slots, setSlots] = useState([]);
  const [form, setForm] = useState(emptySlot);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [editingId, setEditingId] = useState(null);

  const loadTimetables = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await getTimetables();
      setSlots(Array.isArray(data) ? data : data?.timetables || []);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to fetch timetable');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTimetables();
  }, []);

  const hasClash = useMemo(() => {
    return (day, room, startTime, endTime, ignoreId) => {
      const toMinutes = (t) => {
        const [h, m] = t.split(':').map(Number);
        return h * 60 + m;
      };
      const start = toMinutes(startTime);
      const end = toMinutes(endTime);

      return slots.some((slot) => {
        if (ignoreId && slot.id === ignoreId) return false;
        if (slot.day !== day || slot.room !== room) return false;
        const s = toMinutes(slot.startTime);
        const e = toMinutes(slot.endTime);
        return Math.max(s, start) < Math.min(e, end);
      });
    };
  }, [slots]);

  const submitSlot = async () => {
    setSaving(true);
    setError('');

    if (hasClash(form.day, form.room, form.startTime, form.endTime, editingId)) {
      setError('Time clash detected for this room and day');
      setSaving(false);
      return;
    }

    try {
      if (editingId) {
        await updateTimetable(editingId, form);
      } else {
        await createTimetable(form);
      }
      setForm(emptySlot);
      setEditingId(null);
      await loadTimetables();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Save failed');
    } finally {
      setSaving(false);
    }
  };

  const startEdit = (slot) => {
    setEditingId(slot.id);
    setForm({
      course: slot.course,
      teacher: slot.teacher,
      room: slot.room,
      day: slot.day,
      startTime: slot.startTime,
      endTime: slot.endTime,
    });
  };

  const handleDelete = async (slot) => {
    if (!window.confirm('Delete this schedule?')) return;
    setSaving(true);
    setError('');
    try {
      await deleteTimetable(slot.id);
      await loadTimetables();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Delete failed');
    } finally {
      setSaving(false);
    }
  };

  return (
    <Layout>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Timetable</h1>
          <p style={{ color: '#475569', marginTop: '0.35rem' }}>Create weekly schedules and avoid room clashes.</p>
        </div>
        {loading && <span style={{ color: '#94a3b8' }}>Loading...</span>}
      </div>

      {error && (
        <div style={{ marginBottom: '1rem', padding: '1rem', background: '#fef2f2', color: '#b91c1c', border: '1px solid #fecdd3', borderRadius: '0.75rem' }}>
          {error}
        </div>
      )}

      <div style={{ background: 'white', borderRadius: '1rem', padding: '1.5rem', border: '1px solid #e2e8f0', boxShadow: '0 10px 40px rgba(15,23,42,0.08)', marginBottom: '1.5rem' }}>
        <h2 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '1rem' }}>{editingId ? 'Update schedule' : 'Add schedule'}</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1rem' }}>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Course</label>
            <input value={form.course} onChange={(e) => setForm({ ...form, course: e.target.value })} placeholder="Course / subject" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
          </div>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Teacher</label>
            <input value={form.teacher} onChange={(e) => setForm({ ...form, teacher: e.target.value })} placeholder="Faculty name" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
          </div>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Room</label>
            <input value={form.room} onChange={(e) => setForm({ ...form, room: e.target.value })} placeholder="Room code" style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
          </div>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Day</label>
            <select value={form.day} onChange={(e) => setForm({ ...form, day: e.target.value })} style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem', background: 'white' }}>
              {days.map((d) => (
                <option key={d} value={d}>{d}</option>
              ))}
            </select>
          </div>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Start</label>
            <input value={form.startTime} type="time" onChange={(e) => setForm({ ...form, startTime: e.target.value })} style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
          </div>
          <div>
            <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>End</label>
            <input value={form.endTime} type="time" onChange={(e) => setForm({ ...form, endTime: e.target.value })} style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }} />
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem', marginTop: '1rem' }}>
          {editingId && (
            <button onClick={() => { setEditingId(null); setForm(emptySlot); }} style={{ padding: '0.75rem 1.1rem', borderRadius: '0.65rem', border: '1px solid #e2e8f0', background: 'white', cursor: 'pointer' }}>Cancel edit</button>
          )}
          <button
            onClick={submitSlot}
            disabled={saving}
            style={{ padding: '0.75rem 1.25rem', borderRadius: '0.65rem', border: 'none', background: '#22c55e', color: 'white', cursor: saving ? 'not-allowed' : 'pointer' }}
          >
            {saving ? 'Saving...' : editingId ? 'Update' : 'Add to timetable'}
          </button>
        </div>
      </div>

      <div style={{ background: 'white', borderRadius: '1rem', border: '1px solid #e2e8f0', boxShadow: '0 10px 40px rgba(15,23,42,0.08)' }}>
        <div style={{ padding: '1rem', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#475569', fontWeight: 600 }}>Weekly schedule</span>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ background: '#f8fafc' }}>
              <tr>
                {['Course', 'Teacher', 'Room', 'Day', 'Start', 'End', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '0.75rem 1rem', fontSize: '0.9rem', color: '#475569', borderBottom: '1px solid #e2e8f0' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!loading && slots.length === 0 && (
                <tr>
                  <td colSpan={7} style={{ padding: '1.5rem', textAlign: 'center', color: '#94a3b8' }}>No timetable entries.</td>
                </tr>
              )}
              {slots.map((slot) => (
                <tr key={slot.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '0.9rem 1rem', fontWeight: 600, color: '#0f172a' }}>{slot.course}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{slot.teacher}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{slot.room}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{slot.day}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{slot.startTime}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{slot.endTime}</td>
                  <td style={{ padding: '0.9rem 1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                    <button onClick={() => startEdit(slot)} style={{ border: '1px solid #e2e8f0', background: 'white', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }}>Edit</button>
                    <button onClick={() => handleDelete(slot)} style={{ border: 'none', background: '#fee2e2', color: '#b91c1c', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }} disabled={saving}>Delete</button>
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

export default TimetablePage;
