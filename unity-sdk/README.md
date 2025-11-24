# Unity SDK for Clicker Game

Unity integration for the Simple Clicker Game, mirroring the web frontend API.

## Structure

```
unity-sdk/
├── Assets/
│   ├── Scripts/
│   │   ├── GameAPI.cs              # API client (mirrors frontend/api/gameApi.js)
│   │   └── ClickerGameController.cs # Main game controller
│   └── Scenes/
│       └── MainScene.unity          # Main game scene
└── README.md
```

## Setup

1. **Create Unity Project** (2021.3 LTS or newer)
2. **Copy Scripts** to `Assets/Scripts/`
3. **Create Scene** with UI elements:
   - InputField for player address
   - Buttons: Create Session, Click, Buy Upgrade
   - Text elements: Status, Points, Clicks, Click Power
4. **Add ClickerGameController** to a GameObject in scene
5. **Assign UI References** in Inspector

## Usage

### Basic Flow

```csharp
// 1. Create session key
gameAPI.CreateSessionKey(playerAddress, 
    (sessionKey) => {
        // Session created, enable game buttons
    },
    (error) => {
        // Handle error
    }
);

// 2. Click
gameAPI.Click(sessionKey,
    (result) => {
        Debug.Log($"TX: {result.txHash}");
    },
    (error) => {
        Debug.LogError(error);
    }
);

// 3. Buy upgrade
gameAPI.BuyUpgrade(sessionKey,
    (result) => {
        Debug.Log($"TX: {result.txHash}");
    },
    (error) => {
        Debug.LogError(error);
    }
);

// 4. Get game state
gameAPI.GetGameState(playerAddress,
    (state) => {
        Debug.Log($"Points: {state.points}");
    },
    (error) => {
        Debug.LogError(error);
    }
);
```

## API Endpoints

All endpoints match the backend API:

- `POST /create-session-key` - Create session key
- `POST /click` - Execute click
- `POST /buy-upgrade` - Purchase upgrade
- `GET /game-state?player=...` - Get player state

See `../docs/API.md` for full API documentation.

## Configuration

Update `API_URL` in `GameAPI.cs` for production:

```csharp
private const string API_URL = "https://your-backend.onrender.com";
```

## Notes

- Uses Unity's `UnityWebRequest` for HTTP calls
- Session keys stored in `PlayerPrefs` (use secure storage in production)
- Game state refreshes every 5 seconds automatically
- All API calls use coroutines (no async/await)

## Notes

- Uses Unity's `UnityWebRequest` for HTTP calls
- Session keys stored in `PlayerPrefs` (use secure storage in production)
- Game state refreshes every 5 seconds automatically
- All API calls use coroutines (no async/await)

