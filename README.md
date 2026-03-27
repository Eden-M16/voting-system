# 🗳️ VoteChain - Advanced Blockchain Voting System

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.30-363636)](https://soliditylang.org/)
[![Network](https://img.shields.io/badge/Network-Sepolia-3b82f6)](https://sepolia.etherscan.io/)
[![Live Demo](https://img.shields.io/badge/Live-Demo-10b981)](https://eden-m16.github.io/voting-system/voting-app.html)
[![Contract](https://img.shields.io/badge/Contract-Verified-8b5cf6)](https://testnet.routescan.io/address/0x230c92eAFf052d656f245d99C42B39D696AC84d2)

**Live Demo**: [https://eden-m16.github.io/voting-system/voting-app.html](https://eden-m16.github.io/voting-system/voting-app.html)


## 📋 Table of Contents

- [Overview](#overview)
- [New Features](#-new-features-v20)
- [Features](#features)
- [Smart Contract](#smart-contract)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
- [Admin Guide](#admin-guide)
- [Deployment](#deployment)
- [License](#license)

---

## Overview

VoteChain is an advanced decentralized voting application with **weighted voting**, **voter registration**, and **full admin controls**. Every vote is permanently recorded on the Ethereum blockchain.

**What's New in v2.0:**
- ✅ **Weighted Voting** - Different voters can have different vote weights
- ✅ **Voter Registration** - Only registered voters can participate
- ✅ **Election Controls** - Pause, unpause, extend, or end elections
- ✅ **Candidate Descriptions** - Add detailed info for each candidate
- ✅ **Winner Announcement** - Automatic winner calculation

---

## ✨ New Features (v2.0)

| Feature | Description |
|---------|-------------|
| **Weighted Voting** | Give different weights to voters (e.g., 1 vote, 2 votes, 5 votes) |
| **Voter Registration** | Admin registers voters before election starts |
| **Pause Election** | Temporarily stop voting in case of issues |
| **Extend Election** | Add more time to an active election |
| **Candidate Descriptions** | Each candidate can have a description/party/platform |
| **Registration Check** | Voters see if they're registered |
| **Winner Display** | Automatic winner calculation after election ends |

---

## Smart Contract

**Contract Address:** `0x230c92eAFf052d656f245d99C42B39D696AC84d2`

**Network:** Sepolia Testnet

**Compiler:** v0.8.30

### Key Functions

| Function | Who | Description |
|----------|-----|-------------|
| `createElection()` | Admin | Create election with candidates and descriptions |
| `registerVoters()` | Admin | Register voters with weights |
| `vote()` | Registered Voter | Cast vote (counts with weight) |
| `pauseElection()` | Admin | Temporarily pause voting |
| `unpauseElection()` | Admin | Resume voting |
| `extendElection()` | Admin | Add more time |
| `endElection()` | Admin | End election early |
| `getElectionWinner()` | Anyone | Get winner after election ends |

---

## Quick Start

### 1. Install MetaMask
Download from [metamask.io](https://metamask.io/)

### 2. Add Sepolia Network
Network: Sepolia Testnet
RPC URL: https://rpc.sepolia.org
Chain ID: 11155111

### 3. Get Test ETH
Visit [Sepolia Faucet](https://sepolia-faucet.pk910.de/)

### 4. Open the App
[https://eden-m16.github.io/voting-system/voting-app.html](https://eden-m16.github.io/voting-system/voting-app.html)

---

## Usage Guide

### For Voters

1. Connect wallet (must be registered by admin)
2. Browse active elections
3. Click "Vote" on your chosen candidate
4. Confirm transaction
5. View results in real-time

### For Admin (Contract Owner)

1. **Create Election** - Add title, description, duration, candidates
2. **Register Voters** - Add wallet addresses with weights (1-10)
3. **Control Election** - Pause, extend, or end as needed
4. **View Results** - Winner displayed automatically

---

## Admin Guide

### Creating an Election
Title: "Presidential Election 2026"
Description: "Vote for the next president"
Duration: 1440 minutes (24 hours)
Candidates:

Alice Johnson | Progressive Party candidate

Bob Smith | Unity Party candidate

### Registering Voters
Election ID: 0
Voters:

0x123... | Weight: 1

0x456... | Weight: 2

0x789... | Weight: 5

### Election Controls
| Action | When to Use |
|--------|-------------|
| **Pause** | Issue detected, need to investigate |
| **Unpause** | Issue resolved, resume voting |
| **Extend** | More time needed for voting |
| **End** | Election completed early |

---

## Deployment

### Deploy Your Own Contract

1. Open [Remix](https://remix.ethereum.org/)
2. Create `voting.sol` with the advanced contract
3. Compile with Solidity 0.8.30 (optimization on)
4. Set Environment to "Injected Provider - MetaMask"
5. Deploy on Sepolia
6. Update `CONTRACT_ADDRESS` in HTML
7. Push to GitHub Pages

---

## License

MIT License - Free to use, modify, and distribute.

---**

**Built with 🗳️ for transparent and fair elections**