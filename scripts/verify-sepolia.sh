#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
#
# Sepolia-only verification script for migration game stack
# Verifies Sepolia deployment, tests migration, and checks Torii
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Migration Game Stack Verification (Sepolia)${NC}"
echo "=========================================="
echo ""

# Step 1: Check Dojo tools
echo -e "${YELLOW}Step 1: Checking Dojo tools...${NC}"
if ! command -v sozo &> /dev/null; then
    echo -e "${RED}❌ sozo is not installed. Install with: curl -L https://install.dojoengine.org | bash${NC}"
    exit 1
fi

if ! command -v torii &> /dev/null; then
    echo -e "${YELLOW}⚠️  torii not found in PATH${NC}"
    echo "   Install with: curl -L https://install.dojoengine.org | bash"
fi

echo -e "${GREEN}✅ Dojo tools check complete${NC}"
echo ""

# Step 2: Check configuration files
echo -e "${YELLOW}Step 2: Checking configuration files...${NC}"
REQUIRED_FILES=("../config/../config/dojo_sepolia.toml" "torii_sepolia.toml" "Scarb.toml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ $file not found${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✅ All configuration files present${NC}"
echo ""

# Step 3: Check account configuration
echo -e "${YELLOW}Step 3: Checking account configuration...${NC}"
if grep -q "YOUR_ACCOUNT_ADDRESS\|YOUR_PRIVATE_KEY" ../config/../config/dojo_sepolia.toml; then
    echo -e "${RED}❌ Account not configured in ../config/../config/dojo_sepolia.toml${NC}"
    echo "   Please update ../config/../config/dojo_sepolia.toml with your account details"
    exit 1
fi

WORLD_ADDRESS=$(grep -A 5 "\[env\]" ../config/../config/dojo_sepolia.toml | grep "world_address" | cut -d '"' -f 2)
if [ -z "$WORLD_ADDRESS" ] || [ "$WORLD_ADDRESS" = "" ]; then
    echo -e "${YELLOW}⚠️  World address not set in ../config/../config/dojo_sepolia.toml${NC}"
    echo "   This is OK if you haven't deployed yet"
else
    echo -e "${GREEN}✅ World address configured: $WORLD_ADDRESS${NC}"
fi
echo ""

# Step 4: Build for Sepolia
echo -e "${YELLOW}Step 4: Building contracts for Sepolia...${NC}"
echo -e "${BLUE}Running: sozo build --profile sepolia --config ../config/../config/dojo_sepolia.toml${NC}"
sozo build --profile sepolia --config ../config/../config/dojo_sepolia.toml

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"
echo ""

# Step 5: Check deployment status
echo -e "${YELLOW}Step 5: Checking deployment status...${NC}"
if [ -f "manifest_sepolia.json" ]; then
    DEPLOYED_WORLD=$(cat manifest_sepolia.json | jq -r .world.address 2>/dev/null || echo "")
    if [ -n "$DEPLOYED_WORLD" ] && [ "$DEPLOYED_WORLD" != "null" ]; then
        echo -e "${GREEN}✅ Contracts deployed to Sepolia${NC}"
        echo "   World address: $DEPLOYED_WORLD"
        echo ""
        
        # Verify World address matches config
        if [ -n "$WORLD_ADDRESS" ] && [ "$WORLD_ADDRESS" != "" ]; then
            if [ "$WORLD_ADDRESS" = "$DEPLOYED_WORLD" ]; then
                echo -e "${GREEN}✅ World address matches configuration${NC}"
            else
                echo -e "${YELLOW}⚠️  World address mismatch${NC}"
                echo "   Config: $WORLD_ADDRESS"
                echo "   Manifest: $DEPLOYED_WORLD"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  No deployment found. Run './deploy-sepolia.sh' to deploy${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  manifest_sepolia.json not found. Run './deploy-sepolia.sh' to deploy${NC}"
fi
echo ""

# Step 6: Check Torii configuration
echo -e "${YELLOW}Step 6: Checking Torii configuration...${NC}"
TORII_WORLD=$(grep "world_address" torii_sepolia.toml | cut -d '"' -f 2)
if [ -z "$TORII_WORLD" ] || [ "$TORII_WORLD" = "" ]; then
    echo -e "${YELLOW}⚠️  World address not set in torii_sepolia.toml${NC}"
    if [ -n "$DEPLOYED_WORLD" ] && [ "$DEPLOYED_WORLD" != "null" ]; then
        echo "   Update torii_sepolia.toml with: world_address = \"$DEPLOYED_WORLD\""
    fi
else
    echo -e "${GREEN}✅ Torii configured with world address: $TORII_WORLD${NC}"
fi
echo ""

# Step 7: Test migration (if deployed)
if [ -n "$DEPLOYED_WORLD" ] && [ "$DEPLOYED_WORLD" != "null" ]; then
    echo -e "${YELLOW}Step 7: Testing migration system...${NC}"
    echo -e "${BLUE}Run './test-migration.sh sepolia' to test migration${NC}"
    echo ""
    
    read -p "Do you want to test migration now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ ! -f "test-migration.sh" ]; then
            echo -e "${RED}❌ test-migration.sh not found${NC}"
        else
            chmod +x test-migration.sh
            ./test-migration.sh sepolia
        fi
    fi
    echo ""
fi

# Step 8: Check Torii (if running)
echo -e "${YELLOW}Step 8: Checking Torii indexer...${NC}"
if curl -s http://localhost:8080/health > /dev/null 2>&1 || curl -s http://localhost:8080/graphql > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Torii is running on http://localhost:8080${NC}"
    echo ""
    
    # Try a simple GraphQL query
    QUERY='{"query": "{ __schema { types { name } } }"}'
    RESPONSE=$(curl -s -X POST http://localhost:8080/graphql \
        -H "Content-Type: application/json" \
        -d "$QUERY" 2>/dev/null)
    
    if echo "$RESPONSE" | grep -q "data\|__schema"; then
        echo -e "${GREEN}✅ Torii GraphQL is working${NC}"
    else
        echo -e "${YELLOW}⚠️  Torii GraphQL may not be ready${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Torii not running${NC}"
    echo "   Start with: torii --config torii_sepolia.toml"
fi
echo ""

# Summary
echo -e "${GREEN}=========================================="
echo "✅ Sepolia Verification Complete!"
echo "==========================================${NC}"
echo ""

if [ -n "$DEPLOYED_WORLD" ] && [ "$DEPLOYED_WORLD" != "null" ]; then
    echo "Deployment Status:"
    echo "  - World: $DEPLOYED_WORLD"
    echo "  - Network: Sepolia Testnet"
    echo "  - View on Starkscan: https://sepolia.starkscan.co/contract/$DEPLOYED_WORLD"
    echo ""
fi

echo "Next steps:"
if [ -z "$DEPLOYED_WORLD" ] || [ "$DEPLOYED_WORLD" = "null" ]; then
    echo "  1. Run './deploy-sepolia.sh' to deploy contracts"
    echo "  2. Update torii_sepolia.toml with World address"
    echo "  3. Start Torii: torii --config torii_sepolia.toml"
else
    echo "  1. Test migration: ./test-migration.sh sepolia"
    echo "  2. Start Torii (if not running): torii --config torii_sepolia.toml"
    echo "  3. Query GraphQL: http://localhost:8080/graphql"
fi
echo "  4. Proceed with Cartridge Controller integration"
echo ""

