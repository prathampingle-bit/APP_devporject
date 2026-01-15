import { apiClient } from './api';

export const getStats = async () => {
  const { data } = await apiClient.get('/admin/stats/overview');
  return data;
};

export default {
  getStats,
};
