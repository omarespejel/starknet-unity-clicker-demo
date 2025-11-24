# API Documentation

Backend API endpoints for the Simple Clicker Game.

## Base URL

- Development: `http://localhost:3001`
- Production: Configure via `REACT_APP_API_URL`

## Endpoints

### Health Check

**GET** `/health`

Returns server health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### Create Session Key

**POST** `/create-session-key`

Creates or returns a session key for a player.

**Request Body:**
```json
{
  "player": "0x1234..."
}
```

**Response:**
```json
{
  "success": true,
  "sessionKey": {
    "address": "0x5678...",
    "playerAddress": "0x1234...",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

---


### Click

**POST** `/click`

Triggers "click" action in clicker game.

**Request Body:**
```json
{
  "sessionKey": { ... }
}
```

**Response:**
```json
{
  "success": true,
  "txHash": "0x...",
  "message": "Click executed successfully"
}
```

---

### Buy Upgrade

**POST** `/buy-upgrade`

Purchases clicker upgrade.

**Request Body:**
```json
{
  "sessionKey": { ... }
}
```

**Response:**
```json
{
  "success": true,
  "txHash": "0x...",
  "message": "Upgrade purchased successfully"
}
```

---

### Get Game State

**GET** `/game-state?player=0x...`

Returns full player state.

**Query Parameters:**
- `player` (required): Player address

**Response:**
```json
{
  "success": true,
  "player": "0x...",
  "state": {
    "points": "1000",
    "total_clicks": 50,
    "click_power": 2,
    "last_click_time": 1704067200
  }
}
```

---

## Error Responses

All endpoints may return errors in this format:

```json
{
  "error": "Error message",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Status Codes:**
- `400` - Bad Request (missing/invalid parameters)
- `401` - Unauthorized (invalid session key)
- `500` - Internal Server Error

