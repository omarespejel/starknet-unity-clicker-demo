#!/bin/bash

#
# Test script for clicker game
# Tests click and buy_upgrade functions
#

set -e

cd "$(dirname "$0")/.." || exit 1

echo "🎮 Testing Clicker Game"
echo ""

PROFILE=${1:-sepolia}
echo "Using profile: $PROFILE"
echo ""

if [ "$PROFILE" != "sepolia" ]; then
    echo "Error: Only 'sepolia' profile is supported"
    echo "Usage: ./test-clicker.sh sepolia"
    exit 1
fi

echo "Test 1: Clicking..."
echo "Executing click..."
sozo execute gg-clicker click \
    --profile "$PROFILE" \
    --wait

if [ $? -eq 0 ]; then
    echo "✅ Click successful!"
else
    echo "❌ Click failed!"
    exit 1
fi

echo ""
echo "Waiting 3 seconds before upgrading..."
sleep 3

echo ""
echo "Test 2: Buying upgrade..."
echo "Note: This will only work if you have enough points (100+)"
sozo execute gg-clicker buy_upgrade \
    --profile "$PROFILE" \
    --wait

if [ $? -eq 0 ]; then
    echo "✅ Upgrade successful!"
else
    echo "⚠️  Upgrade failed (might not have enough points - click more!)"
fi

echo ""
echo "✅ Tests complete!"
echo ""
echo "Check your score:"
sozo inspect --profile "$PROFILE" 2>&1 | grep -i "PlayerScore\|gg-clicker" | head -5

