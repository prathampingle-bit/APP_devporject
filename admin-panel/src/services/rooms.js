import { apiClient } from './api';

export const getRooms = async () => {
  const { data } = await apiClient.get('/admin/rooms');
  return data;
};

export const createRoom = async (payload) => {
  const { data } = await apiClient.post('/admin/rooms', payload);
  return data;
};

export const updateRoom = async (id, payload) => {
  const { data } = await apiClient.patch(`/admin/rooms/${id}`, payload);
  return data;
};

export const deleteRoom = async (id) => {
  const { data } = await apiClient.delete(`/admin/rooms/${id}`);
  return data;
};

export default {
  getRooms,
  createRoom,
  updateRoom,
  deleteRoom,
};
