import { executeSystem } from '../services/dojoService.js';
import { getSessionKey, validateSessionKey } from '../services/sessionKeyService.js';

/**
 * POST /click
 * Triggers "click" action in clicker game (gasless via Cartridge)
 */
async function click(req, res, next) {
  try {
    const { sessionKey } = req.body;

    if (!sessionKey) {
      return res.status(400).json({
        error: 'Missing required field: sessionKey'
      });
    }

    // Validate session key
    const storedSessionKey = getSessionKey(sessionKey.playerAddress || sessionKey);
    if (!storedSessionKey || !validateSessionKey(storedSessionKey)) {
      return res.status(401).json({
        error: 'Invalid session key'
      });
    }

    const playerAddress = storedSessionKey.playerAddress || sessionKey.playerAddress || sessionKey;

    // Execute click on Dojo world with gasless support
    // System name format: namespace::system_name
    const result = await executeSystem('gg-clicker::click', [], playerAddress);

    res.json({
      success: true,
      txHash: result.txHash,
      gasless: result.gasless || true, // Indicates gasless transaction
      message: 'Click executed successfully (gasless)'
    });
  } catch (error) {
    next(error);
  }
}

/**
 * POST /buy-upgrade
 * Purchases clicker upgrade (gasless via Cartridge)
 */
async function buyUpgrade(req, res, next) {
  try {
    const { sessionKey } = req.body;

    if (!sessionKey) {
      return res.status(400).json({
        error: 'Missing required field: sessionKey'
      });
    }

    // Validate session key
    const storedSessionKey = getSessionKey(sessionKey.playerAddress || sessionKey);
    if (!storedSessionKey || !validateSessionKey(storedSessionKey)) {
      return res.status(401).json({
        error: 'Invalid session key'
      });
    }

    const playerAddress = storedSessionKey.playerAddress || sessionKey.playerAddress || sessionKey;

    // Execute upgrade purchase on Dojo world with gasless support
    // System name format: namespace::system_name
    const result = await executeSystem('gg-clicker::buy_upgrade', [], playerAddress);

    res.json({
      success: true,
      txHash: result.txHash,
      gasless: result.gasless || true, // Indicates gasless transaction
      message: 'Upgrade purchased successfully (gasless)'
    });
  } catch (error) {
    next(error);
  }
}

export default { click, buyUpgrade };

