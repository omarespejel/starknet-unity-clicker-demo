#!/usr/bin/env node

/**
 * Test Cartridge Controller & Paymaster Integration
 * Tests the integration without requiring a running server
 */

import { SESSION_POLICIES, executeGaslessSystem } from './src/services/cartridgeService.js';
import { executeSystem } from './src/services/dojoService.js';
import dotenv from 'dotenv';

dotenv.config();

const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testCartridgeIntegration() {
  console.log('🧪 Testing Cartridge Controller & Paymaster Integration\n');
  console.log('='.repeat(60));
  console.log('');

  let passed = 0;
  let failed = 0;

  // Test 1: Check SESSION_POLICIES export
  console.log('Test 1: SESSION_POLICIES export');
  try {
    if (SESSION_POLICIES && SESSION_POLICIES.contracts) {
      const worldAddress = Object.keys(SESSION_POLICIES.contracts)[0];
      const methods = SESSION_POLICIES.contracts[worldAddress]?.methods || [];
      log(`  ✅ SESSION_POLICIES exported`, 'green');
      log(`     World: ${worldAddress}`, 'green');
      log(`     Methods: ${methods.length}`, 'green');
      methods.forEach(m => log(`       - ${m.name}`, 'green'));
      passed++;
    } else {
      throw new Error('SESSION_POLICIES structure invalid');
    }
  } catch (error) {
    log(`  ❌ Failed: ${error.message}`, 'red');
    failed++;
  }
  console.log('');

  // Test 2: Check Cartridge RPC configuration
  console.log('Test 2: Cartridge RPC configuration');
  try {
    const rpcUrl = process.env.STARKNET_RPC_URL || 'https://api.cartridge.gg/x/starknet/sepolia';
    if (rpcUrl.includes('cartridge.gg')) {
      log(`  ✅ Cartridge RPC configured: ${rpcUrl}`, 'green');
      passed++;
    } else {
      log(`  ⚠️  RPC not using Cartridge: ${rpcUrl}`, 'yellow');
      failed++;
    }
  } catch (error) {
    log(`  ❌ Failed: ${error.message}`, 'red');
    failed++;
  }
  console.log('');

  // Test 3: Check account configuration
  console.log('Test 3: Account configuration');
  try {
    if (process.env.ACCOUNT_ADDRESS && process.env.PRIVATE_KEY) {
      log(`  ✅ Account configured`, 'green');
      log(`     Address: ${process.env.ACCOUNT_ADDRESS.substring(0, 10)}...`, 'green');
      passed++;
    } else {
      log(`  ⚠️  Account not configured (using defaults)`, 'yellow');
      log(`     Set ACCOUNT_ADDRESS and PRIVATE_KEY in .env`, 'yellow');
      // Don't fail, just warn
    }
  } catch (error) {
    log(`  ❌ Failed: ${error.message}`, 'red');
    failed++;
  }
  console.log('');

  // Test 4: Check function exports
  console.log('Test 4: Function exports');
  try {
    if (typeof executeGaslessSystem === 'function') {
      log(`  ✅ executeGaslessSystem exported`, 'green');
      passed++;
    } else {
      throw new Error('executeGaslessSystem not a function');
    }
    
    if (typeof executeSystem === 'function') {
      log(`  ✅ executeSystem exported`, 'green');
      passed++;
    } else {
      throw new Error('executeSystem not a function');
    }
  } catch (error) {
    log(`  ❌ Failed: ${error.message}`, 'red');
    failed++;
  }
  console.log('');

  // Test 5: Check Dojo world address
  console.log('Test 5: Dojo world address');
  try {
    const worldAddress = process.env.WORLD_ADDRESS || '0x036a97624274017898f269fa20ba5f44d0b586e7d0ec1ebef98b8d76926c1bed';
    if (worldAddress && worldAddress.startsWith('0x')) {
      log(`  ✅ World address configured: ${worldAddress.substring(0, 10)}...`, 'green');
      passed++;
    } else {
      throw new Error('Invalid world address');
    }
  } catch (error) {
    log(`  ❌ Failed: ${error.message}`, 'red');
    failed++;
  }
  console.log('');

  // Summary
  console.log('='.repeat(60));
  console.log('');
  console.log('Summary:');
  log(`  Passed: ${passed}`, 'green');
  if (failed > 0) {
    log(`  Failed: ${failed}`, 'red');
  }
  console.log('');

  if (failed === 0) {
    log('✅ All static tests passed!', 'green');
    console.log('');
    log('📝 Next steps:', 'yellow');
    console.log('   1. Start backend: npm run dev');
    console.log('   2. Run full integration test: ../scripts/test-cartridge.sh');
    console.log('');
    return true;
  } else {
    log('❌ Some tests failed. Please fix the issues above.', 'red');
    console.log('');
    return false;
  }
}

// Run tests
testCartridgeIntegration().catch(error => {
  log(`\n❌ Test suite failed: ${error.message}`, 'red');
  process.exit(1);
});

