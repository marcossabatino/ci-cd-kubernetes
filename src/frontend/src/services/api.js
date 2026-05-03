import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

export const getAgents = () => api.get('/agents');

export const sendMessage = (agentId, message, context = []) =>
  api.post(`/agents/${agentId}/message`, { message, context });

export const getHealthStatus = () => axios.get('http://localhost:3001/health/live');

export default api;
