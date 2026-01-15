import axios from 'axios';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api';

export const apiClient = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error?.response?.status;

    if (status === 401) {
      localStorage.removeItem('token');
      if (window.location.pathname !== '/login') {
        window.location.replace('/login');
      }
    }

    if (status === 403) {
      if (window.location.pathname !== '/access-denied') {
        window.location.replace('/access-denied');
      }
    }

    return Promise.reject(error);
  }
);

const api = {
  auth: {
    login: async (email, password) => {
      const { data } = await apiClient.post('/auth/login', { email, password });
      return data;
    },
    me: async () => {
      const { data } = await apiClient.get('/auth/me');
      return data;
    },
  },
};

export default api;
