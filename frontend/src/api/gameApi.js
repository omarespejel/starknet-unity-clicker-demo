import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

export async function createSessionKey(playerAddress) {
  const response = await api.post('/create-session-key', { player: playerAddress });
  return response.data;
}

export async function click(sessionKey) {
  const response = await api.post('/click', { sessionKey });
  return response.data;
}

export async function buyUpgrade(sessionKey) {
  const response = await api.post('/buy-upgrade', { sessionKey });
  return response.data;
}

export async function getGameState(playerAddress) {
  const response = await api.get('/game-state', {
    params: { player: playerAddress }
  });
  return response.data.state;
}

export default {
  createSessionKey,
  click,
  buyUpgrade,
  getGameState
};

