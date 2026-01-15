import { apiClient } from './api';

export const getActiveSessions = async () => {
  const { data } = await apiClient.get('/admin/sessions/active');
  return data;
};

export const endSession = async (id) => {
  const { data } = await apiClient.post(`/admin/sessions/${id}/end`);
  return data;
};

export default {
  getActiveSessions,
  endSession,
};
