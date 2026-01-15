import { apiClient } from './api';

export const getUsers = async () => {
  const { data } = await apiClient.get('/admin/users');
  return data;
};

export const createUser = async (payload) => {
  const { data } = await apiClient.post('/admin/users', payload);
  return data;
};

export const updateUser = async (id, payload) => {
  const { data } = await apiClient.patch(`/admin/users/${id}`, payload);
  return data;
};

export const resetUserPassword = async (id, password) => {
  const { data } = await apiClient.patch(`/admin/users/${id}`, { password });
  return data;
};

export const deleteUser = async (id) => {
  const { data } = await apiClient.delete(`/admin/users/${id}`);
  return data;
};

export default {
  getUsers,
  createUser,
  updateUser,
  resetUserPassword,
  deleteUser,
};
