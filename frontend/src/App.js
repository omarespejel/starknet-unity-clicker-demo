import React, { useState, useEffect } from 'react';
import './styles/App.css';
import GameControls from './components/GameControls';
import GameState from './components/GameState';
import StatusDisplay from './components/StatusDisplay';
import { createSessionKey, click, buyUpgrade, getGameState } from './api/gameApi';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

function App() {
  const [playerAddress, setPlayerAddress] = useState('');
  const [sessionKey, setSessionKey] = useState(null);
  const [gameState, setGameState] = useState(null);
  const [status, setStatus] = useState({ message: '', type: 'info' });
  const [loading, setLoading] = useState(false);

  // Load session key from localStorage on mount
  useEffect(() => {
    const stored = localStorage.getItem('sessionKey');
    const storedPlayer = localStorage.getItem('playerAddress');
    if (stored && storedPlayer) {
      setSessionKey(JSON.parse(stored));
      setPlayerAddress(storedPlayer);
      refreshGameState(storedPlayer);
    }
  }, []);

  // Refresh game state periodically
  useEffect(() => {
    if (playerAddress) {
      const interval = setInterval(() => {
        refreshGameState(playerAddress);
      }, 5000); // Refresh every 5 seconds
      return () => clearInterval(interval);
    }
  }, [playerAddress]);

  const refreshGameState = async (address) => {
    try {
      const state = await getGameState(address);
      setGameState(state);
    } catch (error) {
      console.error('Failed to refresh game state:', error);
    }
  };

  const handleCreateSession = async () => {
    if (!playerAddress) {
      setStatus({ message: 'Please enter player address', type: 'error' });
      return;
    }

    setLoading(true);
    try {
      const result = await createSessionKey(playerAddress);
      setSessionKey(result.sessionKey);
      localStorage.setItem('sessionKey', JSON.stringify(result.sessionKey));
      localStorage.setItem('playerAddress', playerAddress);
      setStatus({ message: 'Session key created successfully!', type: 'success' });
      refreshGameState(playerAddress);
    } catch (error) {
      setStatus({ message: `Failed to create session: ${error.message}`, type: 'error' });
    } finally {
      setLoading(false);
    }
  };


  const handleClick = async () => {
    if (!sessionKey) {
      setStatus({ message: 'Session key required', type: 'error' });
      return;
    }

    setLoading(true);
    try {
      const result = await click(sessionKey);
      setStatus({ message: `Click executed! TX: ${result.txHash}`, type: 'success' });
      setTimeout(() => refreshGameState(playerAddress), 2000);
    } catch (error) {
      setStatus({ message: `Click failed: ${error.message}`, type: 'error' });
    } finally {
      setLoading(false);
    }
  };

  const handleBuyUpgrade = async () => {
    if (!sessionKey) {
      setStatus({ message: 'Session key required', type: 'error' });
      return;
    }

    setLoading(true);
    try {
      const result = await buyUpgrade(sessionKey);
      setStatus({ message: `Upgrade purchased! TX: ${result.txHash}`, type: 'success' });
      setTimeout(() => refreshGameState(playerAddress), 3000);
    } catch (error) {
      setStatus({ message: `Upgrade failed: ${error.message}`, type: 'error' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🎮 Simple Clicker Game</h1>
        <p>On-chain clicker game built with Dojo & Starknet</p>
      </header>

      <main className="App-main">
        <div className="container">
          <section className="setup-section">
            <h2>Setup</h2>
            <div className="input-group">
              <label>Player Address (Starknet):</label>
              <input
                type="text"
                value={playerAddress}
                onChange={(e) => setPlayerAddress(e.target.value)}
                placeholder="0x..."
                disabled={!!sessionKey}
              />
            </div>
            <button onClick={handleCreateSession} disabled={loading || !!sessionKey}>
              {sessionKey ? 'Session Active' : 'Create Wallet (Session Key)'}
            </button>
          </section>

          <section className="game-section">
            <h2>Clicker Game</h2>
            <GameControls
              onClick={handleClick}
              onBuyUpgrade={handleBuyUpgrade}
              loading={loading}
              disabled={!sessionKey}
            />
            <GameState state={gameState} />
          </section>

          <StatusDisplay status={status} />
        </div>
      </main>
    </div>
  );
}

export default App;

