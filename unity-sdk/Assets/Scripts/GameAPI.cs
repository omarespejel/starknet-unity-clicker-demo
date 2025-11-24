using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// GameAPI - Mirrors frontend/src/api/gameApi.js
/// Handles all API calls to the backend
/// </summary>
public class GameAPI : MonoBehaviour
{
    private const string API_URL = "http://localhost:3001"; // Update for production
    
    [Serializable]
    public class SessionKeyResponse
    {
        public bool success;
        public SessionKeyData sessionKey;
    }
    
    [Serializable]
    public class SessionKeyData
    {
        public string address;
        public string playerAddress;
        public string createdAt;
    }
    
    [Serializable]
    public class GameStateResponse
    {
        public bool success;
        public string player;
        public GameStateData state;
    }
    
    [Serializable]
    public class GameStateData
    {
        public string points;
        public int total_clicks;
        public int click_power;
        public long last_click_time;
    }
    
    [Serializable]
    public class TransactionResponse
    {
        public bool success;
        public string txHash;
        public string message;
    }
    
    /// <summary>
    /// Create or get session key for a player
    /// </summary>
    public IEnumerator CreateSessionKey(string playerAddress, Action<SessionKeyData> onSuccess, Action<string> onError)
    {
        var json = $"{{\"player\":\"{playerAddress}\"}}";
        yield return PostRequest("/create-session-key", json, (response) => {
            try
            {
                var result = JsonUtility.FromJson<SessionKeyResponse>(response);
                if (result.success)
                {
                    onSuccess?.Invoke(result.sessionKey);
                }
                else
                {
                    onError?.Invoke("Failed to create session key");
                }
            }
            catch (Exception e)
            {
                onError?.Invoke($"Parse error: {e.Message}");
            }
        }, onError);
    }
    
    /// <summary>
    /// Execute click action
    /// </summary>
    public IEnumerator Click(SessionKeyData sessionKey, Action<TransactionResponse> onSuccess, Action<string> onError)
    {
        var json = JsonUtility.ToJson(sessionKey);
        yield return PostRequest("/click", json, (response) => {
            try
            {
                var result = JsonUtility.FromJson<TransactionResponse>(response);
                if (result.success)
                {
                    onSuccess?.Invoke(result);
                }
                else
                {
                    onError?.Invoke("Click failed");
                }
            }
            catch (Exception e)
            {
                onError?.Invoke($"Parse error: {e.Message}");
            }
        }, onError);
    }
    
    /// <summary>
    /// Buy upgrade
    /// </summary>
    public IEnumerator BuyUpgrade(SessionKeyData sessionKey, Action<TransactionResponse> onSuccess, Action<string> onError)
    {
        var json = JsonUtility.ToJson(sessionKey);
        yield return PostRequest("/buy-upgrade", json, (response) => {
            try
            {
                var result = JsonUtility.FromJson<TransactionResponse>(response);
                if (result.success)
                {
                    onSuccess?.Invoke(result);
                }
                else
                {
                    onError?.Invoke("Buy upgrade failed");
                }
            }
            catch (Exception e)
            {
                onError?.Invoke($"Parse error: {e.Message}");
            }
        }, onError);
    }
    
    /// <summary>
    /// Get player game state
    /// </summary>
    public IEnumerator GetGameState(string playerAddress, Action<GameStateData> onSuccess, Action<string> onError)
    {
        var url = $"{API_URL}/game-state?player={UnityWebRequest.EscapeURL(playerAddress)}";
        yield return GetRequest(url, (response) => {
            try
            {
                var result = JsonUtility.FromJson<GameStateResponse>(response);
                if (result.success)
                {
                    onSuccess?.Invoke(result.state);
                }
                else
                {
                    onError?.Invoke("Failed to get game state");
                }
            }
            catch (Exception e)
            {
                onError?.Invoke($"Parse error: {e.Message}");
            }
        }, onError);
    }
    
    private IEnumerator PostRequest(string endpoint, string json, Action<string> onSuccess, Action<string> onError)
    {
        using (var request = new UnityWebRequest($"{API_URL}{endpoint}", "POST"))
        {
            byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(json);
            request.uploadHandler = new UploadHandlerRaw(bodyRaw);
            request.downloadHandler = new DownloadHandlerBuffer();
            request.SetRequestHeader("Content-Type", "application/json");
            
            yield return request.SendWebRequest();
            
            if (request.result == UnityWebRequest.Result.Success)
            {
                onSuccess?.Invoke(request.downloadHandler.text);
            }
            else
            {
                onError?.Invoke($"Request failed: {request.error}");
            }
        }
    }
    
    private IEnumerator GetRequest(string url, Action<string> onSuccess, Action<string> onError)
    {
        using (var request = UnityWebRequest.Get(url))
        {
            yield return request.SendWebRequest();
            
            if (request.result == UnityWebRequest.Result.Success)
            {
                onSuccess?.Invoke(request.downloadHandler.text);
            }
            else
            {
                onError?.Invoke($"Request failed: {request.error}");
            }
        }
    }
}

