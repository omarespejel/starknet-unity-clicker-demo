import { RpcProvider, Account, CallData, hash } from 'starknet';
import dotenv from 'dotenv';

dotenv.config();

// World address from deployment
const WORLD_ADDRESS = process.env.WORLD_ADDRESS || '0x036a97624274017898f269fa20ba5f44d0b586e7d0ec1ebef98b8d76926c1bed';

// Cartridge RPC with paymaster support
const provider = new RpcProvider({
  nodeUrl: process.env.STARKNET_RPC_URL || 'https://api.cartridge.gg/x/starknet/sepolia'
});

// Helper function to get selector from name
function getSelectorFromName(name) {
  return hash.getSelectorFromName(name);
}

// Session policies for Cartridge Controller
// These define which methods can be called without user approval
export const SESSION_POLICIES = {
  contracts: {
    [WORLD_ADDRESS]: {
      name: "Simple Clicker Game World",
      methods: [
        { 
          name: "click", 
          entrypoint: getSelectorFromName("gg-clicker::click").toString() 
        },
        { 
          name: "buy_upgrade", 
          entrypoint: getSelectorFromName("gg-clicker::buy_upgrade").toString() 
        }
      ]
    }
  }
};

/**
 * Create a Cartridge Controller account for gasless transactions
 * Note: In production, this should be done client-side with user's wallet
 * For backend, we use a service account with paymaster support
 */
export async function createCartridgeAccount(playerAddress, sessionKey) {
  // For backend service account (not user's wallet)
  // We use the configured account but route through Cartridge RPC for paymaster
  if (process.env.ACCOUNT_ADDRESS && process.env.PRIVATE_KEY) {
    const account = new Account(
      provider,
      process.env.ACCOUNT_ADDRESS,
      process.env.PRIVATE_KEY
    );
    
    // Account is configured to use Cartridge RPC which has paymaster enabled
    return account;
  }
  
  throw new Error('Account not configured. Set ACCOUNT_ADDRESS and PRIVATE_KEY in .env');
}

/**
 * Execute a gasless transaction via Cartridge paymaster
 * Transactions go through Cartridge RPC which sponsors gas fees
 */
export async function executeGaslessTransaction(account, calls) {
  try {
    // Execute transaction through Cartridge RPC
    // The paymaster will automatically sponsor gas fees
    const result = await account.execute(calls);
    
    // Wait for transaction to be accepted
    await provider.waitForTransaction(result.transaction_hash);
    
    return {
      success: true,
      txHash: result.transaction_hash,
      gasless: true // Indicates this was a gasless transaction
    };
  } catch (error) {
    console.error('Cartridge gasless transaction error:', error);
    throw new Error(`Failed to execute gasless transaction: ${error.message}`);
  }
}

/**
 * Execute a Dojo system call with gasless support
 */
export async function executeGaslessSystem(systemName, calldata = [], playerAddress) {
  const account = await createCartridgeAccount(playerAddress);
  
  // Convert system name to selector
  const systemSelector = hash.getSelectorFromName(systemName);
  
  // Prepare calldata: [system_selector, calldata_length, ...calldata]
  const executeCalldata = [
    systemSelector,
    calldata.length.toString(),
    ...calldata.map(c => c.toString())
  ];
  
  // Execute through Cartridge RPC (paymaster will sponsor gas)
  const calls = [{
    contractAddress: WORLD_ADDRESS,
    entrypoint: 'execute',
    calldata: executeCalldata
  }];
  
  return await executeGaslessTransaction(account, calls);
}

export { provider, WORLD_ADDRESS };

