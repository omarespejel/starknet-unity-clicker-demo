# Unity Integration Guide

How to integrate the Simple Clicker Game API into Unity.

## Overview

The Unity client mirrors the web frontend by calling the same backend API endpoints. This ensures consistency across platforms.

## Setup

### 1. Unity Project Structure

```
Assets/
├── Scripts/
│   ├── WalletManager.cs      # Session key management
│   ├── GameAPI.cs            # API client (mirrors frontend/api/gameApi.js)
│   ├── GameController.cs     # Game logic and UI
│   └── Models/
│       ├── GameState.cs      # Data models
│       └── SessionKey.cs
└── Scenes/
    └── MainScene.unity
```

### 2. API Client

Create `GameAPI.cs` that mirrors `frontend/src/api/gameApi.js`:

```csharp
using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

public class GameAPI : MonoBehaviour
{
    private const string API_URL = "http://localhost:3001"; // or your production URL
    
    public IEnumerator CreateSessionKey(string playerAddress, System.Action<SessionKey> callback)
    {
        var json = $"{{\"player\":\"{playerAddress}\"}}";
        yield return PostRequest("/create-session-key", json, (response) => {
            var result = JsonUtility.FromJson<ApiResponse<SessionKey>>(response);
            callback(result.sessionKey);
        });
    }
    
    // Similar methods for click, buyUpgrade, getGameState
    // See frontend/src/api/gameApi.js for reference
}
```

### 3. Game Controller

Create `GameController.cs` for UI integration:

```csharp
public class ClickerGameController : MonoBehaviour
{
    public GameAPI api;
    private SessionKey sessionKey;
    
    public void OnCreateSessionButtonClick()
    {
        StartCoroutine(api.CreateSessionKey(playerAddress, (key) => {
            sessionKey = key;
            PlayerPrefs.SetString("sessionKey", JsonUtility.ToJson(key));
        }));
    }
    
    public void OnClickButtonClick()
    {
        StartCoroutine(api.Click(sessionKey, (result) => {
            RefreshGameState();
        }));
    }
    
    public void OnBuyUpgradeButtonClick()
    {
        StartCoroutine(api.BuyUpgrade(sessionKey, (result) => {
            RefreshGameState();
        }));
    }
    
    private void RefreshGameState()
    {
        StartCoroutine(api.GetGameState(playerAddress, (state) => {
            UpdateUI(state);
        }));
    }
}
```

## API Endpoints

All endpoints match the web API. See `API.md` for full documentation:

- `POST /create-session-key` - Create session key
- `POST /click` - Execute click action
- `POST /buy-upgrade` - Purchase upgrade
- `GET /game-state?player=...` - Get player state

## Data Models

Mirror the frontend data structures:

```csharp
[Serializable]
public class SessionKey
{
    public string address;
    public string playerAddress;
    public string createdAt;
}

[Serializable]
public class GameState
{
    public string points;
    public int total_clicks;
    public int click_power;
    public long last_click_time;
}
```

## Best Practices

1. **Use Coroutines** for async API calls (Unity doesn't support async/await well)
2. **Store session keys** securely (use Unity's PlayerPrefs or secure storage)
3. **Handle errors** gracefully with user-friendly messages
4. **Refresh state** periodically (every 5-10 seconds)
5. **Show loading states** during transactions

## Testing

1. Start backend: `cd backend && npm run dev`
2. Open Unity project
3. Run scene and test all actions
4. Check backend logs for API calls

## Production

Update `API_URL` in `GameAPI.cs` to your production backend URL:

```csharp
private const string API_URL = "https://your-backend.onrender.com";
```

## Example Flow

```csharp
// 1. Create Session Key
StartCoroutine(api.CreateSessionKey(playerAddress, (sessionKey) => {
    Debug.Log($"Session created: {sessionKey.address}");
}));

// 2. Click
StartCoroutine(api.Click(sessionKey, (result) => {
    Debug.Log($"Click TX: {result.txHash}");
    RefreshGameState();
}));

// 3. Buy Upgrade
StartCoroutine(api.BuyUpgrade(sessionKey, (result) => {
    Debug.Log($"Upgrade TX: {result.txHash}");
    RefreshGameState();
}));

// 4. Get Game State
StartCoroutine(api.GetGameState(playerAddress, (state) => {
    Debug.Log($"Points: {state.points}, Clicks: {state.total_clicks}");
}));
```

## Resources

- See `unity-sdk/Assets/Scripts/` for Unity scripts
- See `frontend/src/api/gameApi.js` for API reference
- See `API.md` for endpoint documentation
- See `unity-sdk/README.md` for Unity setup guide

