import { getPlayerState } from '../services/dojoService.js';

/**
 * GET /game-state?player=...
 * Returns full player state
 */
async function getState(req, res, next) {
  try {
    const { player } = req.query;

    if (!player) {
      return res.status(400).json({
        error: 'Missing required query parameter: player'
      });
    }

    // Get player state from Torii or contract
    const state = await getPlayerState(player);

    res.json({
      success: true,
      player,
      state: state || {
        points: '0',
        total_clicks: 0,
        click_power: 1,
        last_click_time: 0
      }
    });
  } catch (error) {
    next(error);
  }
}

export default { getState };

