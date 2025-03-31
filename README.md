# Contribution Vault

A decentralized system for tracking, rewarding, and incentivizing contributions to projects on the blockchain.

## Overview

Contribution Vault is a smart contract platform that enables projects to reward contributors with points based on their efforts. The system includes features for tracking contribution consistency, locking points for additional benefits, and managing a sustainable reward economy.

## Features

- **Contribution Tracking**: Record and validate contributions to projects
- **Consistency Bonuses**: Reward contributors who maintain regular activity
- **Point Redemption**: Allow contributors to redeem earned points
- **Point Locking**: Enable contributors to lock points for future benefits
- **Vault Statistics**: Track overall contribution metrics and point issuance

## Core Functions

- `start-contribution`: Begin tracking a new contribution effort
- `complete-contribution`: Finalize a contribution and receive points
- `redeem-points`: Exchange accumulated points for benefits
- `lock-points`: Lock points in the vault for future bonuses
- `unlock-points`: Retrieve locked points (with potential penalties for early withdrawal)

## Technical Details

- Maximum vault capacity: 1,000,000 points
- Base contribution reward: 10 points
- Consistency bonus: 2 points per level (up to 7 levels)
- Minimum lock duration: 288 blocks (approximately 2 days)
- Early unlock penalty: 10%

## Getting Started

1. Deploy the contract to your blockchain
2. Contributors can start tracking their contributions
3. Complete contributions to earn points
4. Lock points for additional benefits
5. Redeem points when ready

## Security

The system includes safeguards to prevent exceeding the vault capacity and ensures that only legitimate contributions are rewarded.