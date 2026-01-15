import { apiClient } from './api';

export const getTimetables = async () => {
  const { data } = await apiClient.get('/admin/timetables');
  return data;
};

export const createTimetable = async (payload) => {
  const { data } = await apiClient.post('/admin/timetables', payload);
  return data;
};

export const updateTimetable = async (id, payload) => {
  const { data } = await apiClient.patch(`/admin/timetables/${id}`, payload);
  return data;
};

export const deleteTimetable = async (id) => {
  const { data } = await apiClient.delete(`/admin/timetables/${id}`);
  return data;
};

export default {
  getTimetables,
  createTimetable,
  updateTimetable,
  deleteTimetable,
};
