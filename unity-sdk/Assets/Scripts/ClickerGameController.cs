using UnityEngine;
using UnityEngine.UI;
using System.Collections;

/// <summary>
/// Clicker Game Controller - Main game logic for Unity
/// Mirrors frontend/src/App.js functionality
/// </summary>
public class ClickerGameController : MonoBehaviour
{
    [Header("UI References")]
    [SerializeField] private InputField playerAddressInput;
    [SerializeField] private Button createSessionButton;
    [SerializeField] private Button clickButton;
    [SerializeField] private Button buyUpgradeButton;
    [SerializeField] private Text statusText;
    [SerializeField] private Text pointsText;
    [SerializeField] private Text clicksText;
    [SerializeField] private Text clickPowerText;
    
    private GameAPI gameAPI;
    private GameAPI.SessionKeyData sessionKey;
    private string playerAddress;
    private Coroutine refreshCoroutine;
    
    void Start()
    {
        // Initialize API
        gameAPI = gameObject.AddComponent<GameAPI>();
        
        // Setup button listeners
        createSessionButton.onClick.AddListener(OnCreateSession);
        clickButton.onClick.AddListener(OnClick);
        buyUpgradeButton.onClick.AddListener(OnBuyUpgrade);
        
        // Load saved session key
        LoadSessionKey();
        
        // Disable game buttons until session is created
        clickButton.interactable = false;
        buyUpgradeButton.interactable = false;
    }
    
    void OnDestroy()
    {
        if (refreshCoroutine != null)
        {
            StopCoroutine(refreshCoroutine);
        }
    }
    
    private void LoadSessionKey()
    {
        string savedKey = PlayerPrefs.GetString("sessionKey", "");
        string savedPlayer = PlayerPrefs.GetString("playerAddress", "");
        
        if (!string.IsNullOrEmpty(savedKey) && !string.IsNullOrEmpty(savedPlayer))
        {
            sessionKey = JsonUtility.FromJson<GameAPI.SessionKeyData>(savedKey);
            playerAddress = savedPlayer;
            playerAddressInput.text = playerAddress;
            playerAddressInput.interactable = false;
            
            // Enable game buttons
            clickButton.interactable = true;
            buyUpgradeButton.interactable = true;
            
            // Start refreshing game state
            StartRefreshingState();
        }
    }
    
    private void OnCreateSession()
    {
        playerAddress = playerAddressInput.text;
        
        if (string.IsNullOrEmpty(playerAddress))
        {
            UpdateStatus("Please enter player address", Color.red);
            return;
        }
        
        createSessionButton.interactable = false;
        UpdateStatus("Creating session key...", Color.yellow);
        
        StartCoroutine(gameAPI.CreateSessionKey(playerAddress, 
            (sessionKeyData) => {
                sessionKey = sessionKeyData;
                
                // Save to PlayerPrefs
                PlayerPrefs.SetString("sessionKey", JsonUtility.ToJson(sessionKey));
                PlayerPrefs.SetString("playerAddress", playerAddress);
                
                // Disable address input
                playerAddressInput.interactable = false;
                
                // Enable game buttons
                clickButton.interactable = true;
                buyUpgradeButton.interactable = true;
                
                UpdateStatus("Session key created!", Color.green);
                
                // Start refreshing game state
                StartRefreshingState();
            },
            (error) => {
                UpdateStatus($"Error: {error}", Color.red);
                createSessionButton.interactable = true;
            }
        ));
    }
    
    private void OnClick()
    {
        if (sessionKey == null)
        {
            UpdateStatus("Please create session key first", Color.red);
            return;
        }
        
        clickButton.interactable = false;
        UpdateStatus("Clicking...", Color.yellow);
        
        StartCoroutine(gameAPI.Click(sessionKey,
            (result) => {
                UpdateStatus($"Click executed! TX: {result.txHash}", Color.green);
                clickButton.interactable = true;
                
                // Refresh state after a delay
                Invoke(nameof(RefreshGameState), 2f);
            },
            (error) => {
                UpdateStatus($"Click failed: {error}", Color.red);
                clickButton.interactable = true;
            }
        ));
    }
    
    private void OnBuyUpgrade()
    {
        if (sessionKey == null)
        {
            UpdateStatus("Please create session key first", Color.red);
            return;
        }
        
        buyUpgradeButton.interactable = false;
        UpdateStatus("Buying upgrade...", Color.yellow);
        
        StartCoroutine(gameAPI.BuyUpgrade(sessionKey,
            (result) => {
                UpdateStatus($"Upgrade purchased! TX: {result.txHash}", Color.green);
                buyUpgradeButton.interactable = true;
                
                // Refresh state after a delay
                Invoke(nameof(RefreshGameState), 2f);
            },
            (error) => {
                UpdateStatus($"Upgrade failed: {error}", Color.red);
                buyUpgradeButton.interactable = true;
            }
        ));
    }
    
    private void StartRefreshingState()
    {
        if (refreshCoroutine != null)
        {
            StopCoroutine(refreshCoroutine);
        }
        
        refreshCoroutine = StartCoroutine(RefreshStateCoroutine());
    }
    
    private IEnumerator RefreshStateCoroutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(5f); // Refresh every 5 seconds
            RefreshGameState();
        }
    }
    
    private void RefreshGameState()
    {
        if (string.IsNullOrEmpty(playerAddress))
            return;
        
        StartCoroutine(gameAPI.GetGameState(playerAddress,
            (state) => {
                UpdateGameState(state);
            },
            (error) => {
                Debug.LogWarning($"Failed to refresh state: {error}");
            }
        ));
    }
    
    private void UpdateGameState(GameAPI.GameStateData state)
    {
        if (state != null)
        {
            pointsText.text = $"Points: {state.points}";
            clicksText.text = $"Clicks: {state.total_clicks}";
            clickPowerText.text = $"Power: {state.click_power}";
        }
    }
    
    private void UpdateStatus(string message, Color color)
    {
        statusText.text = message;
        statusText.color = color;
        Debug.Log($"[ClickerGame] {message}");
    }
}

