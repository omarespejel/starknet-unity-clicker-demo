# Scripts Documentation

This document describes the utility scripts available in the Simple Clicker Game project.

## generate-context.sh

Generates a comprehensive LLM context file by concatenating all key source files from the project.

### Usage

```bash
./generate-context.sh
```

### What It Includes

- **Preamble**: LLM goal and expertise areas
- **Directory Structure**: Clean project tree (excludes node_modules, build artifacts, etc.)
- **Core Files**: README.md, Scarb.toml, dojo_sepolia.toml, etc.
- **Backend Code**: All Express.js source files
- **Frontend Code**: All React components and API clients
- **Cairo Contracts**: All Dojo systems and models
- **Unity SDK**: C# scripts for Unity integration
- **Documentation**: All markdown files from docs/
- **Deployment**: Render.yaml, docker-compose.yaml, deployment scripts
- **Configuration**: .env.example files (never includes .env with secrets)

### Output

Creates a timestamped file: `clicker-game-context-YYYY-MM-DD_HH-MM-SS_TZ.txt`

### Use Cases

- **Code Reviews**: Get comprehensive feedback on architecture
- **LLM Assistance**: Provide full context for AI coding assistants
- **Documentation**: Generate project overviews
- **Onboarding**: Help new developers understand the codebase

### Example

```bash
./generate-context.sh
# Output: clicker-game-context-2025-11-21_20-03-52_-03.txt
# File size: ~50KB
# Total lines: ~2000
```

---

## scripts/test-cartridge.sh

Tests Cartridge Controller & Paymaster integration to verify gasless transactions work correctly.

### Usage

```bash
# Start backend first
cd backend && npm run dev

# In another terminal, run tests
./scripts/test-cartridge.sh
```

### Environment Variables

- `BACKEND_URL`: Backend API URL (default: http://localhost:3001)
- `PLAYER_ADDRESS`: Player address for testing (default: from config)

### What It Tests

1. **Backend Health**: Checks if backend is running
2. **Session Key Creation**: Tests `/create-session-key` endpoint
3. **Gasless Click**: Tests `/click` endpoint with gasless flag
4. **Gasless Upgrade**: Tests `/buy-upgrade` endpoint with gasless flag
5. **Game State**: Tests `/game-state` endpoint
6. **Configuration**: Verifies Cartridge config in dojo_sepolia.toml
7. **Backend Service**: Verifies Cartridge service implementation

### Expected Output

```
🧪 Testing Cartridge Controller & Paymaster Integration
========================================================

✅ Backend is running
✅ Session key created successfully
✅ Click executed successfully
✅ Gasless transaction confirmed
✅ Buy upgrade executed successfully
✅ Gasless transaction confirmed
✅ Game state retrieved successfully
✅ Cartridge Controller and Paymaster enabled
✅ Cartridge RPC endpoint configured
✅ Cartridge service file exists
✅ Session policies defined
✅ Gasless execution function found

✅ All Cartridge Controller & Paymaster tests passed!
```

### Troubleshooting

**Backend not running:**
```bash
cd backend && npm run dev
```

**Missing .env file:**
```bash
cd backend
cp .env.example .env
# Edit .env with your configuration
```

**Cartridge not configured:**
- Check `dojo_sepolia.toml` has `enable_controller = true` and `enable_paymaster = true`
- Verify `rpc_url` points to `https://api.cartridge.gg/x/starknet/sepolia`

---

## Other Scripts

### scripts/deploy-sepolia.sh
Deploys Dojo world to Sepolia testnet.

### scripts/test-clicker.sh
Tests clicker game functions (click, buy_upgrade) via sozo.

### scripts/verify-sepolia.sh
Verifies Sepolia deployment and Torii indexer.

---

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `generate-context.sh` | Generate LLM context | Code reviews, AI assistance |
| `scripts/test-cartridge.sh` | Test Cartridge integration | After Cartridge setup, before deployment |
| `scripts/deploy-sepolia.sh` | Deploy to Sepolia | When deploying contracts |
| `scripts/test-clicker.sh` | Test game functions | After contract deployment |
| `scripts/verify-sepolia.sh` | Verify deployment | After deployment |

---

## Tips

1. **Run `generate-context.sh` regularly** to keep LLM context up-to-date
2. **Test Cartridge integration** before deploying to production
3. **Check script permissions** - all scripts should be executable (`chmod +x`)
4. **Review output files** - context files can be large, review before sharing

