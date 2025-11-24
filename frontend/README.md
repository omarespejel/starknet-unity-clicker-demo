# Migration Game Frontend

React frontend for the Migration Clicker Game.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (optional):
```bash
REACT_APP_API_URL=http://localhost:3001
```

## Running

### Development
```bash
npm start
```

Opens at `http://localhost:3000`

### Production Build
```bash
npm run build
```

## Features

- Create session keys for gasless transactions
- Migrate users from ImmutableX to Starknet
- Claim migration bonuses
- Play clicker game (click, buy upgrades)
- Real-time game state display

## Components

- `App.js` - Main application component
- `GameControls` - Action buttons
- `GameState` - Player stats display
- `StatusDisplay` - Status messages

## API Integration

All API calls are in `src/api/gameApi.js` and connect to the backend API.

