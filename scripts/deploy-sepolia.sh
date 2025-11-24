#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
#
# Deployment script for Starknet Sepolia testnet
# This script automates the deployment process
#

set -e  # Exit on error

echo "🚀 Starting deployment to Starknet Sepolia testnet..."
echo ""

# Check if required tools are installed
command -v sozo >/dev/null 2>&1 || { echo "❌ Error: sozo is not installed. Install it with: curl -L https://install.dojoengine.org | bash"; exit 1; }

# Check if dojo_sepolia.toml exists
if [ ! -f "dojo_sepolia.toml" ]; then
    echo "❌ Error: dojo_sepolia.toml not found!"
    exit 1
fi

# Check if account is configured
if grep -q "YOUR_ACCOUNT_ADDRESS" dojo_sepolia.toml; then
    echo "⚠️  Warning: Account address not configured in dojo_sepolia.toml"
    echo "Please update dojo_sepolia.toml with your account details first."
    exit 1
fi

# Build the project
echo "📦 Building project for Sepolia..."
sozo build --profile sepolia

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Deploy to Sepolia
echo "🌐 Deploying to Sepolia testnet..."
sozo migrate --profile sepolia

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the World address from the output above"
echo "2. Update torii_sepolia.toml with the World address"
echo "3. Start Torii indexer: torii --config torii_sepolia.toml"
echo ""
