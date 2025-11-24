# Migration Game Backend API

Backend API for the Migration Clicker Game, built with Express.js and integrated with Dojo/Starknet.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

3. Update `.env` with your Starknet RPC URL, World address, and account credentials.

## Running

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

## API Endpoints

See `../docs/API.md` for full API documentation.

### Quick Reference

- `POST /create-session-key` - Create or get session key
- `POST /migrate-user` - Migrate user from ImmutableX
- `POST /claim-bonus` - Claim migration bonus
- `POST /click` - Execute click action
- `POST /buy-upgrade` - Purchase upgrade
- `GET /game-state?player=...` - Get player state
- `GET /health` - Health check

## Testing

```bash
npm test
```

## Architecture

- `controllers/` - Route handlers
- `services/` - Business logic
  - `dojoService.js` - Dojo world integration
  - `cartridgeService.js` - Cartridge Controller & Paymaster (gasless transactions)
  - `sessionKeyService.js` - Session key management
- `models/` - Data schemas
- `tests/` - Unit and integration tests

## Cartridge Integration

This backend uses Cartridge Controller and Paymaster for gasless transactions. See `CARTRIDGE_SETUP.md` for details.

- ✅ Cartridge RPC endpoint configured
- ✅ Paymaster enabled (gasless transactions)
- ✅ Session policies defined
- ✅ All game actions are gasless

