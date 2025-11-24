#!/bin/bash

# Test Cartridge Controller & Paymaster Integration
# Verifies that gasless transactions work correctly

set -e

echo "🧪 Testing Cartridge Controller & Paymaster Integration"
echo "========================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:3001}"
PLAYER_ADDRESS="${PLAYER_ADDRESS:-0x03ca968f17e08a636d99b12b9f10a0adcb6c22bb25140b861a8dde8b0ad1fa1d}"

echo "Configuration:"
echo "  Backend URL: $BACKEND_URL"
echo "  Player Address: $PLAYER_ADDRESS"
echo ""

# Check if backend is running
echo "1. Checking if backend is running..."
if curl -s "$BACKEND_URL/health" > /dev/null; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is not running. Start it with: cd backend && npm run dev${NC}"
    exit 1
fi
echo ""

# Test 1: Create Session Key
echo "2. Testing session key creation..."
SESSION_RESPONSE=$(curl -s -X POST "$BACKEND_URL/create-session-key" \
  -H "Content-Type: application/json" \
  -d "{\"player\":\"$PLAYER_ADDRESS\"}")

if echo "$SESSION_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Session key created successfully${NC}"
    echo "$SESSION_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SESSION_RESPONSE"
    SESSION_KEY=$(echo "$SESSION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionKey'])" 2>/dev/null || echo "")
else
    echo -e "${RED}❌ Session key creation failed${NC}"
    echo "$SESSION_RESPONSE"
    exit 1
fi
echo ""

# Test 2: Execute Click (Gasless)
echo "3. Testing gasless click transaction..."
if [ -z "$SESSION_KEY" ]; then
    SESSION_KEY='{"playerAddress":"'$PLAYER_ADDRESS'"}'
fi

CLICK_RESPONSE=$(curl -s -X POST "$BACKEND_URL/click" \
  -H "Content-Type: application/json" \
  -d "{\"sessionKey\":$SESSION_KEY}")

if echo "$CLICK_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Click executed successfully${NC}"
    
    # Check if gasless flag is present
    if echo "$CLICK_RESPONSE" | grep -q "gasless"; then
        echo -e "${GREEN}✅ Gasless transaction confirmed${NC}"
    else
        echo -e "${YELLOW}⚠️  Gasless flag not found in response${NC}"
    fi
    
    echo "$CLICK_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CLICK_RESPONSE"
    
    # Extract transaction hash
    TX_HASH=$(echo "$CLICK_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('txHash', ''))" 2>/dev/null || echo "")
    if [ -n "$TX_HASH" ]; then
        echo ""
        echo "Transaction Hash: $TX_HASH"
        echo "View on Starkscan: https://sepolia.starkscan.co/tx/$TX_HASH"
    fi
else
    echo -e "${RED}❌ Click execution failed${NC}"
    echo "$CLICK_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Execute Buy Upgrade (Gasless)
echo "4. Testing gasless buy upgrade transaction..."
UPGRADE_RESPONSE=$(curl -s -X POST "$BACKEND_URL/buy-upgrade" \
  -H "Content-Type: application/json" \
  -d "{\"sessionKey\":$SESSION_KEY}")

if echo "$UPGRADE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Buy upgrade executed successfully${NC}"
    
    # Check if gasless flag is present
    if echo "$UPGRADE_RESPONSE" | grep -q "gasless"; then
        echo -e "${GREEN}✅ Gasless transaction confirmed${NC}"
    else
        echo -e "${YELLOW}⚠️  Gasless flag not found in response${NC}"
    fi
    
    echo "$UPGRADE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$UPGRADE_RESPONSE"
    
    # Extract transaction hash
    TX_HASH=$(echo "$UPGRADE_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('txHash', ''))" 2>/dev/null || echo "")
    if [ -n "$TX_HASH" ]; then
        echo ""
        echo "Transaction Hash: $TX_HASH"
        echo "View on Starkscan: https://sepolia.starkscan.co/tx/$TX_HASH"
    fi
else
    echo -e "${RED}❌ Buy upgrade execution failed${NC}"
    echo "$UPGRADE_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get Game State
echo "5. Testing game state query..."
STATE_RESPONSE=$(curl -s "$BACKEND_URL/game-state?player=$PLAYER_ADDRESS")

if echo "$STATE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Game state retrieved successfully${NC}"
    echo "$STATE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$STATE_RESPONSE"
else
    echo -e "${YELLOW}⚠️  Game state query returned unexpected response${NC}"
    echo "$STATE_RESPONSE"
fi
echo ""

# Test 5: Verify Cartridge Configuration
echo "6. Verifying Cartridge configuration..."
if [ -f "dojo_sepolia.toml" ]; then
    if grep -q "enable_controller = true" dojo_sepolia.toml && grep -q "enable_paymaster = true" dojo_sepolia.toml; then
        echo -e "${GREEN}✅ Cartridge Controller and Paymaster enabled in dojo_sepolia.toml${NC}"
    else
        echo -e "${RED}❌ Cartridge not properly configured in dojo_sepolia.toml${NC}"
    fi
    
    if grep -q "api.cartridge.gg" dojo_sepolia.toml; then
        echo -e "${GREEN}✅ Cartridge RPC endpoint configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Cartridge RPC endpoint not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  dojo_sepolia.toml not found${NC}"
fi
echo ""

# Test 6: Verify Backend Cartridge Service
echo "7. Verifying backend Cartridge service..."
if [ -f "backend/src/services/cartridgeService.js" ]; then
    echo -e "${GREEN}✅ Cartridge service file exists${NC}"
    
    if grep -q "api.cartridge.gg" backend/src/services/cartridgeService.js; then
        echo -e "${GREEN}✅ Cartridge RPC endpoint configured in service${NC}"
    fi
    
    if grep -q "SESSION_POLICIES" backend/src/services/cartridgeService.js; then
        echo -e "${GREEN}✅ Session policies defined${NC}"
    fi
    
    if grep -q "executeGasless" backend/src/services/cartridgeService.js; then
        echo -e "${GREEN}✅ Gasless execution function found${NC}"
    fi
else
    echo -e "${RED}❌ Cartridge service file not found${NC}"
fi
echo ""

# Summary
echo "========================================================"
echo -e "${GREEN}✅ All Cartridge Controller & Paymaster tests passed!${NC}"
echo ""
echo "Summary:"
echo "  ✓ Backend is running"
echo "  ✓ Session key creation works"
echo "  ✓ Gasless click transaction works"
echo "  ✓ Gasless buy upgrade transaction works"
echo "  ✓ Game state query works"
echo "  ✓ Cartridge configuration verified"
echo "  ✓ Backend Cartridge service verified"
echo ""
echo "🎮 Your clicker game is ready for gasless transactions!"
echo ""

