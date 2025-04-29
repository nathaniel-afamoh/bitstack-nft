# BitStack NFT Protocol

**Version:** 1.0  
**Language:** Clarity (Stacks Smart Contract Language)  
**Secured By:** Bitcoin via Stacks Layer 2

## Overview

**BitStack** is a next-generation NFT protocol deployed on the Stacks blockchain. It integrates advanced DeFi features into the NFT ecosystem, providing robust utility and liquidity options backed by Bitcoin finality. The protocol introduces collateralized NFT minting, a native marketplace, fractional ownership, and staking with yield generation.

## Features

### Collateralized NFT Minting

Mint NFTs by locking STX tokens as collateral. A minimum collateralization ratio ensures economic security and stability.

### On-Chain Marketplace

Buy and sell NFTs directly on-chain with low protocol fees (2.5%). Listings are open and transparent.

### Fractional Ownership via Share Tokens

Split NFT ownership into fungible shares, enabling broader participation and liquidity.

### NFT Staking

Stake NFTs to earn yield paid in STX. Rewards accumulate over time based on a fixed annual yield rate.

### Bitcoin Finality

All transactions achieve finality through Bitcoin via the Stacks consensus mechanism.

## Smart Contract Details

### Constants

- `min-collateral-ratio`: `u150` (150%)
- `protocol-fee`: `u25` (2.5%)
- `yield-rate`: `u50` (5% annual, basis points)
- Error codes defined for access control, validation, and financial integrity

### Data Maps

- `tokens`: NFT metadata including owner, URI, collateral, staking status, and shares
- `token-listings`: Marketplace records with pricing and status
- `fractional-ownership`: Share ownership per address per token
- `staking-rewards`: Tracks accumulated yield and claim timestamps

## Core Functions

### Minting

```clojure
(mint-nft (uri) (collateral))
```

Validates URI and STX balance before minting NFT with locked collateral.

### Transfers

```clojure
(transfer-nft (token-id) (recipient))
```

Transfers NFT to a recipient, enforcing staking and ownership checks.

### Marketplace

```clojure
(list-nft (token-id) (price))
(purchase-nft (token-id))
```

Enables listing and purchasing of NFTs with enforced price and ownership validation.

### Fractional Ownership

```clojure
(transfer-shares (token-id) (recipient) (share-amount))
```

Allows partial transfer of NFT ownership via share tokens.

### Staking

```clojure
(stake-nft (token-id))
(unstake-nft (token-id))
```

Enables and disables staking of NFTs, tracking rewards and timestamp.

### Rewards

```clojure
(calculate-rewards (token-id))
```

Read-only function to compute staking rewards based on block time and yield rate.

## Helper Functions

### URI & Recipient Validation

- `validate-uri`: Ensures URI is a valid ASCII string
- `validate-recipient`: Prevents self-transfer to the contract

### Math Safety

- `safe-add`: Prevents overflow in share calculations

## Deployment Notes

- Requires deployment on the Stacks blockchain
- Contract owner is defined as the deployer (`tx-sender`)
- Protocol fees are transferred to the contract treasury for sustainability

## Security Considerations

- Overflow-safe arithmetic
- Access-controlled functions (owner and token-holder only)
- Immutable rules enforced at protocol level (e.g. staking, transfers)
