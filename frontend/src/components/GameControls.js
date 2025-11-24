import React from 'react';

function GameControls({ onClick, onBuyUpgrade, loading, disabled }) {
  return (
    <div className="game-controls">
      {(onClick || onBuyUpgrade) && (
        <div className="button-group">
          {onClick && (
            <button onClick={onClick} disabled={loading || disabled} className="click-button">
              {loading ? 'Clicking...' : '🖱️ Click!'}
            </button>
          )}
          {onBuyUpgrade && (
            <button onClick={onBuyUpgrade} disabled={loading || disabled}>
              {loading ? 'Buying...' : 'Buy Upgrade'}
            </button>
          )}
        </div>
      )}
    </div>
  );
}

export default GameControls;

