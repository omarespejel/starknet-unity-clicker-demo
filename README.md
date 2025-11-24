# Migration Clicker Game

A simple on-chain clicker game demo built with Dojo, Starknet, and modern web/mobile stack.

## Project Structure

```
migration-game/
├── backend/              # Express.js API server
├── frontend/             # React web frontend
├── unity-sdk/            # Unity integration (optional)
├── deployment/           # Deployment configs (Render, Docker)
├── docs/                 # Documentation
└── src/                  # Dojo Cairo contracts
```

## Quick Start

### 1. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm run dev
```

Backend runs on `http://localhost:3001`

### 2. Frontend Setup

```bash
cd frontend
npm install
npm start
```

Frontend opens at `http://localhost:3000`

### 3. Dojo Contracts

See main README for Dojo world deployment.

## Features

- ✅ **Session Keys** - Gasless transactions via Cartridge Controller
- ✅ **Clicker Game** - On-chain clicker with upgrades
- ✅ **Real-time State** - Torii GraphQL integration
- ✅ **Web & Unity** - Cross-platform compatibility
- ✅ **RESTful API** - Clean API for easy integration

## Game Mechanics

- **Click** - Earn points by clicking (1 point per click by default)
- **Upgrade** - Buy upgrades to increase click power
- **Stats** - Track points, total clicks, and click power

## API Endpoints

See `docs/API.md` for full API documentation.

- `POST /create-session-key` - Create session key
- `POST /click` - Execute click action
- `POST /buy-upgrade` - Purchase upgrade
- `GET /game-state?player=...` - Get player state

## Documentation

- **API Docs**: `docs/API.md`
- **Quick Start**: `docs/QUICKSTART.md`
- **Unity Integration**: `docs/UNITY_INTEGRATION.md`
- **Demo Guide**: `docs/DEMO.md`

## Deployment

### Render.com

1. Push code to GitHub
2. Connect to Render
3. Use `deployment/render.yaml` config
4. Set environment variables

### Docker

```bash
cd deployment
docker-compose up
```

## Development

### Backend

```bash
cd backend
npm run dev    # Development with auto-reload
npm start      # Production
npm test       # Run tests
```

### Frontend

```bash
cd frontend
npm start      # Development server
npm run build  # Production build
npm test       # Run tests
```

## Architecture

- **Backend**: Express.js with Starknet.js for Dojo integration
- **Frontend**: React with Axios for API calls
- **Contracts**: Dojo Cairo systems and models
- **Indexer**: Torii for real-time state queries

## License

MIT
