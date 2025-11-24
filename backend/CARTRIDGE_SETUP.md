# Cartridge Controller & Paymaster Setup

This backend uses Cartridge Controller and Paymaster for gasless transactions.

## Configuration

### Dojo World (`dojo_sepolia.toml`)
```toml
[cartridge]
enable_controller = true
enable_paymaster = true

[env]
rpc_url = "https://api.cartridge.gg/x/starknet/sepolia"
```

### Backend Service (`cartridgeService.js`)
- Uses Cartridge RPC endpoint (paymaster enabled)
- Defines session policies for allowed methods
- Executes transactions through Cartridge RPC for gasless support

## How It Works

1. **Session Policies**: Define which contract methods can be called without user approval
2. **Cartridge RPC**: All transactions go through `https://api.cartridge.gg/x/starknet/sepolia`
3. **Paymaster**: Automatically sponsors gas fees for transactions
4. **Gasless Transactions**: Users pay $0 in gas fees

## Session Policies

Current policies allow:
- `gg-clicker::click` - Execute click action
- `gg-clicker::buy_upgrade` - Purchase upgrade

These are defined in `src/services/cartridgeService.js`:

```javascript
export const SESSION_POLICIES = {
  contracts: {
    [WORLD_ADDRESS]: {
      name: "Simple Clicker Game World",
      methods: [
        { name: "click", entrypoint: "..." },
        { name: "buy_upgrade", entrypoint: "..." }
      ]
    }
  }
};
```

## Client-Side Integration

For full Cartridge Controller integration, clients should:

1. **Install Cartridge Controller SDK** (if available):
   ```bash
   npm install @cartridge/controller
   ```
   
   Note: Cartridge Controller SDK is primarily for client-side (browser/Unity).
   Backend uses Cartridge RPC endpoint directly for paymaster support.

2. **Initialize Controller**:
   ```javascript
   import Controller from "@cartridge/controller";
   
   const controller = new Controller({
     policies: SESSION_POLICIES
   });
   ```

3. **Connect Wallet**:
   ```javascript
   const account = await controller.connect();
   ```

4. **Execute Gasless Transactions**:
   ```javascript
   const tx = await account.execute([{
     contractAddress: WORLD_ADDRESS,
     entrypoint: "execute",
     calldata: [...]
   }]);
   // Gas fees automatically sponsored by paymaster!
   ```

## Backend API

The backend API endpoints automatically use Cartridge for gasless transactions:

- `POST /click` - Gasless click action
- `POST /buy-upgrade` - Gasless upgrade purchase

All responses include `gasless: true` to indicate gasless transactions.

## Notes

- **Backend**: Uses Cartridge RPC with paymaster support
- **Client**: Should use Cartridge Controller SDK for full session key support
- **Gas Fees**: Automatically sponsored by Cartridge paymaster
- **Session Keys**: Created client-side with Cartridge Controller (backend stores metadata)

## Resources

- [Cartridge Controller Docs](https://docs.cartridge.gg/controller)
- [Session Policies](https://docs.cartridge.gg/controller/sessions)
- [Paymaster](https://docs.cartridge.gg/controller/paymaster)

