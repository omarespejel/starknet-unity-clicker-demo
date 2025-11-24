import { RpcProvider, Account } from 'starknet';
import dotenv from 'dotenv';
import { SESSION_POLICIES } from './cartridgeService.js';

dotenv.config();

// In-memory store for session keys (use Redis/DB in production)
const sessionKeys = new Map();

/**
 * Generate or retrieve a session key for a player
 * Note: In production, session keys should be created client-side with Cartridge Controller
 * This is a simplified backend version for API compatibility
 */
export function createSessionKey(playerAddress) {
  // Check if session key already exists
  if (sessionKeys.has(playerAddress)) {
    return sessionKeys.get(playerAddress);
  }

  // Generate a new session key
  // In production, this should be done client-side with Cartridge Controller SDK
  const privateKey = `0x${Array.from({ length: 64 }, () => 
    Math.floor(Math.random() * 16).toString(16)
  ).join('')}`;

  const provider = new RpcProvider({
    nodeUrl: process.env.STARKNET_RPC_URL || 'https://api.cartridge.gg/x/starknet/sepolia'
  });

  // Session key metadata
  // Note: Actual session keys should be created via Cartridge Controller with SESSION_POLICIES
  const sessionKey = {
    privateKey,
    address: null, // Will be computed when account is created
    playerAddress,
    createdAt: new Date().toISOString(),
    policies: SESSION_POLICIES, // Include policies for reference
    gasless: true // Indicates this session supports gasless transactions
  };

  sessionKeys.set(playerAddress, sessionKey);
  
  return sessionKey;
}

/**
 * Get session key for a player
 */
export function getSessionKey(playerAddress) {
  return sessionKeys.get(playerAddress) || null;
}

/**
 * Validate session key
 */
export function validateSessionKey(sessionKey) {
  if (!sessionKey) {
    return false;
  }

  // Check if session key exists in our store
  const stored = sessionKeys.get(sessionKey.playerAddress);
  return stored && stored.privateKey === sessionKey.privateKey;
}

/**
 * Create account from session key for transaction signing
 */
export async function getSessionAccount(sessionKey) {
  if (!sessionKey || !sessionKey.privateKey) {
    throw new Error('Invalid session key');
  }

  const provider = new RpcProvider({
    nodeUrl: process.env.STARKNET_RPC_URL || 'https://api.cartridge.gg/x/starknet/sepolia'
  });

  // In production, use Cartridge Controller SDK to create session keys
  // This uses Cartridge RPC which has paymaster support for gasless transactions
  const account = new Account(provider, sessionKey.address || '0x0', sessionKey.privateKey);
  
  // Account is configured to use Cartridge RPC (paymaster enabled)
  return account;
}

export { sessionKeys };

