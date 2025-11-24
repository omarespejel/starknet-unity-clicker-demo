import { createSessionKey, getSessionKey } from '../services/sessionKeyService.js';

/**
 * POST /create-session-key
 * Creates or returns a session key for a player
 */
async function create(req, res, next) {
  try {
    const { player } = req.body;

    if (!player) {
      return res.status(400).json({
        error: 'Missing required field: player'
      });
    }

    const sessionKey = createSessionKey(player);

    res.json({
      success: true,
      sessionKey: {
        address: sessionKey.address || 'pending',
        playerAddress: sessionKey.playerAddress,
        createdAt: sessionKey.createdAt
      }
    });
  } catch (error) {
    next(error);
  }
}

export default { create };

