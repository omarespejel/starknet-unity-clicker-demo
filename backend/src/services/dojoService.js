import { RpcProvider, Contract, CallData } from 'starknet';
import { executeGaslessSystem, provider, WORLD_ADDRESS } from './cartridgeService.js';
import dotenv from 'dotenv';

dotenv.config();

/**
 * Execute a system call on the Dojo world with gasless support
 * Uses Cartridge paymaster to sponsor gas fees
 * Uses sozo execute format: namespace::system_name
 */
export async function executeSystem(systemName, calldata = [], playerAddress) {
  try {
    // Execute through Cartridge service for gasless transactions
    return await executeGaslessSystem(systemName, calldata, playerAddress);
  } catch (error) {
    console.error('Dojo execute error:', error);
    throw new Error(`Failed to execute ${systemName}: ${error.message}`);
  }
}

/**
 * Call a view function on the Dojo world
 */
export async function callView(contractAddress, entrypoint, calldata = []) {
  try {
    const contract = new Contract([], contractAddress, provider);
    const result = await contract.call(entrypoint, calldata);
    return result;
  } catch (error) {
    console.error('View call error:', error);
    throw new Error(`Failed to call ${entrypoint}: ${error.message}`);
  }
}

/**
 * Get player state from Torii GraphQL
 */
export async function getPlayerState(playerAddress) {
  const toriiUrl = process.env.TORII_URL || 'http://localhost:8080';
  
  try {
    const query = `
      query GetPlayerState($player: String!) {
        models(where: { player: { eq: $player } }) {
          edges {
            node {
              ... on ClickerScore {
                points
                total_clicks
                click_power
                last_click_time
              }
            }
          }
        }
      }
    `;

    const response = await fetch(`${toriiUrl}/graphql`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query,
        variables: { player: playerAddress }
      })
    });

    const data = await response.json();
    return data.data?.models?.edges?.[0]?.node || null;
  } catch (error) {
    console.error('Torii query error:', error);
    // Return mock data for development
    return {
      points: '0',
      total_clicks: 0,
      click_power: 1,
      last_click_time: 0
    };
  }
}

export { provider, WORLD_ADDRESS };

