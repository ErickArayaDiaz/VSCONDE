// src/api/api.js
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api'
});

// Agregar token automáticamente si existe
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token'); // o usa contexto
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default api;
