# Quick Start Guide

Get the Simple Clicker Game up and running locally.

## Prerequisites

- Node.js 18+ and npm
- Starknet account with Sepolia testnet ETH
- Dojo world deployed (see main README)

## Setup

### 1. Clone and Install

```bash
cd migration-game

# Install backend dependencies
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration

# Install frontend dependencies
cd ../frontend
npm install
```

### 2. Configure Backend

Edit `backend/.env`:

```env
STARKNET_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia
WORLD_ADDRESS=0x036a97624274017898f269fa20ba5f44d0b586e7d0ec1ebef98b8d76926c1bed
ACCOUNT_ADDRESS=0x...
PRIVATE_KEY=0x...
TORII_URL=http://localhost:8080
PORT=3001
```

### 3. Start Backend

```bash
cd backend
npm run dev
```

Backend runs on `http://localhost:3001`

### 4. Start Frontend

In a new terminal:

```bash
cd frontend
npm start
```

Frontend opens at `http://localhost:3000`

## Testing

### 1. Create Session Key

1. Enter your Starknet player address
2. Click "Create Wallet (Session Key)"
3. Session key is stored in localStorage

### 2. Play Clicker Game

1. Click the "🖱️ Click!" button to earn points
2. Click "Buy Upgrade" to increase click power
3. Watch your stats update in real-time

## Troubleshooting

### Backend won't start

- Check `.env` file exists and is configured
- Ensure port 3001 is not in use
- Check Node.js version: `node --version`

### Frontend can't connect to backend

- Verify backend is running on port 3001
- Check `REACT_APP_API_URL` in frontend `.env` (if using)
- Check browser console for CORS errors

### Transactions failing

- Verify account has Sepolia ETH
- Check WORLD_ADDRESS matches deployed world
- Ensure Torii is running if using GraphQL queries

## Next Steps

- See `API.md` for full API documentation
- See `UNITY_INTEGRATION.md` for Unity setup
- See `DEMO.md` for demo workflow

