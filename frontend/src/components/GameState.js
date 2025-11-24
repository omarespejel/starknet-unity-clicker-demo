import React from 'react';

function GameState({ state }) {
  if (!state) {
    return <div className="game-state">No game state available. Create a session key to start.</div>;
  }

  return (
    <div className="game-state">
      <h3>Player Stats</h3>
      <div className="stats-grid">
        <div className="stat-item">
          <label>Points:</label>
          <span className="stat-value">{state.points || '0'}</span>
        </div>
        <div className="stat-item">
          <label>Total Clicks:</label>
          <span className="stat-value">{state.total_clicks || 0}</span>
        </div>
        <div className="stat-item">
          <label>Click Power:</label>
          <span className="stat-value">{state.click_power || 1}</span>
        </div>
        <div className="stat-item">
          <label>Last Click:</label>
          <span className="stat-value">
            {state.last_click_time 
              ? new Date(parseInt(state.last_click_time) * 1000).toLocaleTimeString()
              : 'Never'}
          </span>
        </div>
      </div>
    </div>
  );
}

export default GameState;

