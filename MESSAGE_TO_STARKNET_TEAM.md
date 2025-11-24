# CASM Compiled Class Hash Mismatch on Sepolia

Hey team,

I'm stuck on a CASM compiled class hash mismatch when deploying Dojo contracts to Sepolia. Here's what's happening and what I've tried.

## The Problem

Every time I try to declare classes, I get:

```
Mismatch compiled class hash for class with hash 0xe96a69f35952017a2c745cf6f8889884a9347f284156da99ab8e2eaaff30d6
Actual: 0x7934d3f5015e6be5db65804bf15f8c2f604bf021d3ade72ea0b59f241cd5874
Expected: 0x75ca34ee4c2ba060f9b3171173e5d75298fb7fe132633867354ebec6f7b26e4
```

The Sierra class hash matches (class exists on-chain), but the compiled class hash is different. This happens with all my contracts—models, events, and systems.

**Affected classes:**
- `m_ClickerScore` (model)
- `m_Leaderboard` (model)
- `e_ClickerClicked` (event)
- `e_ClickerUpgraded` (event)
- `e_BonusClaimed` (event)
- `clicker` (system contract)

All six classes fail with the same pattern: Sierra hash exists on-chain, but compiled class hash differs.

## What I Know

- Classes were declared before (Sierra hashes match)
- The sequencer compiled them with a different CASM compiler version
- Changing accounts doesn't help—declarations are global
- Even after generating new Sierra class hashes, I still hit the same compiled hash mismatch

**The pattern:**
1. I modify code → new Sierra class hash generated ✅
2. I try to declare → sequencer checks on-chain state
3. Sequencer finds matching Sierra hash → tries to use existing declaration
4. Sequencer compares compiled class hashes → mismatch error ❌

**Example progression:**
- First attempt: Class hash `0x5f1d53c44ccc36073e6d8ce8bb032c1e745e8d9cb73c273138e8e8361f2afd1` → mismatch
- After code changes: Class hash `0x40853fc8017a1136fee8a5a2cb18fa119374fc7d3a0bfea61cb21757fec874b` → mismatch
- After package rename: Class hash `0xe96a69f35952017a2c745cf6f8889884a9347f284156da99ab8e2eaaff30d6` → mismatch

Each time, different Sierra hash, but same "Actual" compiled class hash on-chain (`0x7934d3f5015e6be5db65804bf15f8c2f604bf021d3ade72ea0b59f241cd5874`).

## My Setup

- Cairo 2.13.1
- Sierra 1.7.0
- Scarb 2.13.1
- Dojo 1.8.0
- Sozo 1.8.0
- Sepolia testnet (Cartridge RPC: `https://api.cartridge.gg/x/starknet/sepolia`)
- Sequencer spec: 0.9.0 (from `starknet_specVersion` RPC call)
- Local CASM compiler: 2.13.1 (from generated CASM files)

**Account:**
- Address: `0x078c26a3a5e8c2db04d1298762271abccfeea7da21aa4e0d58ae0370e8ff0cf3`
- Deployed and funded ✅

**World:**
- Address: `0x032c4b5442817f7c7e6c3127dcafd7c5898e97d5f067fd8477437bff3e5bbfd6`
- Deployed successfully ✅
- Contracts not registered (blocked by class declaration)

## What I've Tried

1. **Modified code significantly** to get new Sierra class hashes
   - Added bonus claiming system (`claim_bonus()` function)
   - Added leveling mechanics (level up every 1000 points)
   - Enhanced multiplier system (multiplier increases every 5 upgrades)
   - Added new fields to models (`bonus_points`, `level`)
   - Added new event (`BonusClaimed`)
   - Modified existing events (added `current_level`, `multiplier_used` fields)
   - Changed namespace from `clickergame` to `clickerv2`

2. **Changed package names** multiple times
   - Started: `dojo_starter`
   - Changed to: `clicker_game`
   - Changed to: `unity_clicker_v2`
   - Each change generated new Sierra class hashes, but still hit mismatches

3. **Enabled local CASM generation**
   - Added `casm = true` to `Scarb.toml`
   - Verified CASM files generate correctly
   - Local CASM compiler version: 2.13.1
   - CASM files exist in `target/sepolia/`

4. **Verified local compilation**
   - Code compiles successfully ✅
   - No compilation errors
   - All contracts build correctly

5. **Tried different accounts**
   - Created new account: `0x078c26a3a5e8c2db04d1298762271abccfeea7da21aa4e0d58ae0370e8ff0cf3`
   - Deployed account successfully
   - Same issue persists (declarations are global, not account-specific)

6. **Checked on-chain state**
   - Queried classes via RPC (`starknet_getClass`)
   - Classes exist on-chain
   - Can't query compiled class hash directly (not in RPC response)

7. **Tested individual class declarations**
   - Tried declaring each class separately with `sncast`
   - All fail with same mismatch error
   - Error shows "Actual" (on-chain) vs "Expected" (our build) compiled class hashes

## Technical Details

**CASM Compilation Process:**
1. We compile Cairo → Sierra locally (works fine)
2. We send Sierra bytecode to sequencer
3. Sequencer compiles Sierra → CASM on-chain
4. Sequencer stores compiled class hash

**The Mismatch:**
- Previous declarations: Sequencer used CASM compiler version X
- Current attempt: Sequencer uses CASM compiler version Y
- Result: Same Sierra → Different CASM → Hash mismatch

**What's interesting:**
- The "Actual" compiled class hash stays the same across different Sierra hashes
- This suggests the sequencer might be caching or the on-chain state has these specific compiled hashes locked in
- Even with completely new Sierra class hashes, we hit the same "Actual" compiled hash

**Error pattern:**
```
Transaction error (index: 0)
Message: Mismatch compiled class hash for class with hash <SIERRA_HASH>
Actual: <ON_CHAIN_COMPILED_HASH>  ← Always the same
Expected: <OUR_COMPILED_HASH>      ← Changes with each build
```

## Questions

1. **Is this a known issue?** Are others seeing CASM mismatches on Sepolia? Is there a GitHub issue or discussion thread?

2. **CASM compiler version**: Has the sequencer's CASM compiler version changed recently? How can I check what version the sequencer is using? Is there a way to ensure compatibility?

3. **Class declaration lifecycle**: Once a class is declared with a specific compiled class hash, can it be redeclared with a different compiled class hash if the Sierra class hash is the same? Or is it locked once declared? What's the expected behavior?

4. **Workarounds**: What's the recommended workaround?
   - Should I wait for network state to update?
   - Is there a way to query and reuse existing class declarations?
   - Should I use devnet instead?
   - Is there a way to force new compiled class hashes?

5. **Best practices**: What's the recommended approach when CASM compiler versions differ? Should I pin compiler versions? Is there a compatibility matrix?

6. **Debugging**: Is there a way to see what CASM compiler version was used for existing declarations? Can I query the sequencer's current CASM compiler version?

## The Real Question

Is this expected behavior, or a bug? 

If expected:
- What's the right way to handle it?
- Should I always use devnet for development?
- Is there a process for handling compiler version changes?

If a bug:
- Is there a fix planned?
- What's the workaround in the meantime?
- Should I file a GitHub issue?

The code compiles fine locally. New Sierra hashes generate correctly. The blocker is sequencer-side CASM compilation compatibility.

**What I need:** Either a way to work around this, or confirmation that this is expected and I should use devnet for now.

Any guidance would be helpful. Thanks!

---

**Project**: Dojo clicker game  
**Framework**: Dojo 1.8.0  
**Target**: Sepolia testnet  
**Blocking**: Can't register contracts to world due to class declaration failures
