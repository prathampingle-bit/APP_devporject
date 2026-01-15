import React, { useEffect, useMemo, useState } from 'react';
import Layout from '../components/Layout';
import {
  getUsers,
  createUser,
  updateUser,
  resetUserPassword,
  deleteUser,
} from '../services/users';

const roles = ['ADMIN', 'HOD', 'FACULTY', 'STAFF'];

const emptyForm = {
  name: '',
  email: '',
  department: '',
  role: 'FACULTY',
  password: '',
};

const Modal = ({ title, children, onClose, width = '520px' }) => (
  <div style={{
    position: 'fixed',
    inset: 0,
    background: 'rgba(15,23,42,0.45)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000,
    padding: '1rem',
  }}>
    <div style={{
      width: '100%',
      maxWidth: width,
      background: 'white',
      borderRadius: '1rem',
      boxShadow: '0 25px 70px rgba(15,23,42,0.25)',
      padding: '1.5rem',
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <h2 style={{ fontSize: '1.25rem', fontWeight: 700 }}>{title}</h2>
        <button onClick={onClose} style={{ background: 'transparent', border: 'none', fontSize: '1.25rem', cursor: 'pointer' }}>×</button>
      </div>
      {children}
    </div>
  </div>
);

const UsersPage = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [createModalOpen, setCreateModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [resetModalOpen, setResetModalOpen] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [selectedUser, setSelectedUser] = useState(null);
  const [saving, setSaving] = useState(false);

  const loadUsers = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await getUsers();
      setUsers(Array.isArray(data) ? data : data?.users || []);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to fetch users');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const handleCreate = async () => {
    setSaving(true);
    setError('');
    try {
      await createUser(form);
      setCreateModalOpen(false);
      setForm(emptyForm);
      await loadUsers();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Create failed');
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = async () => {
    if (!selectedUser) return;
    setSaving(true);
    setError('');
    try {
      await updateUser(selectedUser.id, {
        department: form.department,
        role: form.role,
      });
      setEditModalOpen(false);
      setSelectedUser(null);
      setForm(emptyForm);
      await loadUsers();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Update failed');
    } finally {
      setSaving(false);
    }
  };

  const handleResetPassword = async () => {
    if (!selectedUser) return;
    setSaving(true);
    setError('');
    try {
      await resetUserPassword(selectedUser.id, form.password);
      setResetModalOpen(false);
      setSelectedUser(null);
      setForm(emptyForm);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Password reset failed');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (user) => {
    if (!window.confirm(`Delete ${user.name}?`)) return;
    setSaving(true);
    setError('');
    try {
      await deleteUser(user.id);
      await loadUsers();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Delete failed');
    } finally {
      setSaving(false);
    }
  };

  const openEditModal = (user) => {
    setSelectedUser(user);
    setForm({ ...emptyForm, role: user.role, department: user.department || '' });
    setEditModalOpen(true);
  };

  const openResetModal = (user) => {
    setSelectedUser(user);
    setForm({ ...emptyForm, password: '' });
    setResetModalOpen(true);
  };

  const derivedUsers = useMemo(() => users || [], [users]);

  return (
    <Layout>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Users</h1>
          <p style={{ color: '#475569', marginTop: '0.35rem' }}>Manage admins, HODs, faculty and staff.</p>
        </div>
        <button
          onClick={() => setCreateModalOpen(true)}
          style={{
            padding: '0.75rem 1.25rem',
            borderRadius: '0.75rem',
            background: '#2563eb',
            color: 'white',
            border: 'none',
            cursor: 'pointer',
            fontWeight: 600,
            boxShadow: '0 10px 30px rgba(37,99,235,0.3)'
          }}
        >
          + Add User
        </button>
      </div>

      {error && (
        <div style={{
          marginBottom: '1rem',
          padding: '1rem',
          background: '#fef2f2',
          color: '#b91c1c',
          border: '1px solid #fecdd3',
          borderRadius: '0.75rem'
        }}>
          {error}
        </div>
      )}

      <div style={{
        background: 'white',
        borderRadius: '1rem',
        boxShadow: '0 10px 40px rgba(15,23,42,0.08)',
        overflow: 'hidden',
        border: '1px solid #e2e8f0'
      }}>
        <div style={{ padding: '1rem', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#475569', fontWeight: 600 }}>All Users</span>
          {loading && <span style={{ color: '#94a3b8' }}>Loading...</span>}
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ background: '#f8fafc' }}>
              <tr>
                {['Name', 'Email', 'Role', 'Department', 'Status', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '0.75rem 1rem', fontSize: '0.9rem', color: '#475569', borderBottom: '1px solid #e2e8f0' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!loading && derivedUsers.length === 0 && (
                <tr>
                  <td colSpan={6} style={{ padding: '1.5rem', textAlign: 'center', color: '#94a3b8' }}>
                    No users found.
                  </td>
                </tr>
              )}

              {derivedUsers.map((user) => (
                <tr key={user.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '0.9rem 1rem', fontWeight: 600, color: '#0f172a' }}>{user.name}</td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{user.email}</td>
                  <td style={{ padding: '0.9rem 1rem' }}>
                    <span style={{
                      padding: '0.35rem 0.65rem',
                      borderRadius: '999px',
                      background: '#e0f2fe',
                      color: '#075985',
                      fontWeight: 600,
                      fontSize: '0.85rem'
                    }}>
                      {user.role}
                    </span>
                  </td>
                  <td style={{ padding: '0.9rem 1rem', color: '#475569' }}>{user.department || '—'}</td>
                  <td style={{ padding: '0.9rem 1rem' }}>
                    <span style={{
                      padding: '0.35rem 0.65rem',
                      borderRadius: '999px',
                      background: user.active ? '#ecfdf3' : '#f8fafc',
                      color: user.active ? '#166534' : '#475569',
                      fontWeight: 600,
                      fontSize: '0.85rem'
                    }}>
                      {user.active ? 'Active' : 'Disabled'}
                    </span>
                  </td>
                  <td style={{ padding: '0.9rem 1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                    <button
                      onClick={() => openEditModal(user)}
                      style={{ border: '1px solid #e2e8f0', background: 'white', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }}
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => openResetModal(user)}
                      style={{ border: '1px solid #e2e8f0', background: 'white', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }}
                    >
                      Reset Password
                    </button>
                    <button
                      onClick={() => handleDelete(user)}
                      style={{ border: 'none', background: '#fee2e2', color: '#b91c1c', padding: '0.45rem 0.75rem', borderRadius: '0.5rem', cursor: 'pointer' }}
                      disabled={saving}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {createModalOpen && (
        <Modal title="Create User" onClose={() => setCreateModalOpen(false)}>
          <div style={{ display: 'grid', gap: '1rem' }}>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Name</label>
              <input
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                placeholder="Full name"
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
              />
            </div>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Email</label>
              <input
                value={form.email}
                type="email"
                onChange={(e) => setForm({ ...form, email: e.target.value })}
                placeholder="admin@example.com"
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
              />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Role</label>
                <select
                  value={form.role}
                  onChange={(e) => setForm({ ...form, role: e.target.value })}
                  style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem', background: 'white' }}
                >
                  {roles.map((role) => (
                    <option key={role} value={role}>{role}</option>
                  ))}
                </select>
              </div>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Department</label>
                <input
                  value={form.department}
                  onChange={(e) => setForm({ ...form, department: e.target.value })}
                  placeholder="CSE / ECE / ..."
                  style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
                />
              </div>
            </div>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Temporary Password</label>
              <input
                value={form.password}
                type="password"
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                placeholder="Set initial password"
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
              />
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button onClick={() => setCreateModalOpen(false)} style={{ padding: '0.75rem 1.1rem', borderRadius: '0.65rem', border: '1px solid #e2e8f0', background: 'white', cursor: 'pointer' }}>Cancel</button>
              <button
                onClick={handleCreate}
                disabled={saving}
                style={{ padding: '0.75rem 1.25rem', borderRadius: '0.65rem', border: 'none', background: '#2563eb', color: 'white', cursor: saving ? 'not-allowed' : 'pointer' }}
              >
                {saving ? 'Creating...' : 'Create'}
              </button>
            </div>
          </div>
        </Modal>
      )}

      {editModalOpen && (
        <Modal title={`Edit ${selectedUser?.name || ''}`} onClose={() => setEditModalOpen(false)}>
          <div style={{ display: 'grid', gap: '1rem' }}>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Role</label>
              <select
                value={form.role}
                onChange={(e) => setForm({ ...form, role: e.target.value })}
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem', background: 'white' }}
              >
                {roles.map((role) => (
                  <option key={role} value={role}>{role}</option>
                ))}
              </select>
            </div>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>Department</label>
              <input
                value={form.department}
                onChange={(e) => setForm({ ...form, department: e.target.value })}
                placeholder="Department"
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
              />
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button onClick={() => setEditModalOpen(false)} style={{ padding: '0.75rem 1.1rem', borderRadius: '0.65rem', border: '1px solid #e2e8f0', background: 'white', cursor: 'pointer' }}>Cancel</button>
              <button
                onClick={handleEdit}
                disabled={saving}
                style={{ padding: '0.75rem 1.25rem', borderRadius: '0.65rem', border: 'none', background: '#2563eb', color: 'white', cursor: saving ? 'not-allowed' : 'pointer' }}
              >
                {saving ? 'Saving...' : 'Save changes'}
              </button>
            </div>
          </div>
        </Modal>
      )}

      {resetModalOpen && (
        <Modal title={`Reset password for ${selectedUser?.name || ''}`} onClose={() => setResetModalOpen(false)}>
          <div style={{ display: 'grid', gap: '1rem' }}>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.35rem' }}>New Password</label>
              <input
                value={form.password}
                type="password"
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                placeholder="Enter a secure password"
                style={{ width: '100%', padding: '0.75rem', border: '1px solid #e2e8f0', borderRadius: '0.65rem' }}
              />
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button onClick={() => setResetModalOpen(false)} style={{ padding: '0.75rem 1.1rem', borderRadius: '0.65rem', border: '1px solid #e2e8f0', background: 'white', cursor: 'pointer' }}>Cancel</button>
              <button
                onClick={handleResetPassword}
                disabled={saving}
                style={{ padding: '0.75rem 1.25rem', borderRadius: '0.65rem', border: 'none', background: '#0ea5e9', color: 'white', cursor: saving ? 'not-allowed' : 'pointer' }}
              >
                {saving ? 'Updating...' : 'Reset password'}
              </button>
            </div>
          </div>
        </Modal>
      )}
    </Layout>
  );
};

export default UsersPage;
