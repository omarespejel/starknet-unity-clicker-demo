import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import sessionKeyController from './controllers/sessionKeyController.js';
import gameController from './controllers/gameController.js';
import stateController from './controllers/stateController.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.post('/create-session-key', sessionKeyController.create);
app.post('/click', gameController.click);
app.post('/buy-upgrade', gameController.buyUpgrade);
app.get('/game-state', stateController.getState);

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(PORT, () => {
  console.log(`🚀 Backend server running on http://localhost:${PORT}`);
  console.log(`📋 API endpoints available at http://localhost:${PORT}/health`);
});

