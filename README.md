\# ChronoVault



\*\*Live demo:\*\* \[chronovault-arc.netlify.app](https://chronovault-arc.netlify.app/)



A time-locked message vault built on \[Arc Testnet](https://docs.arc.network) — Circle's EVM-compatible Layer-1 blockchain. Write a message, pick a date, and the smart contract itself refuses to reveal it until that moment arrives. No admin key, no backend — the wait is enforced entirely on-chain.



!\[ChronoVault](https://img.shields.io/badge/network-Arc%20Testnet-c9a15c) !\[Solidity](https://img.shields.io/badge/solidity-%5E0.8.24-363636)



\## Features



\- \*\*Time-locked capsules\*\* — lock a message until a future timestamp; `getMessage()` reverts on-chain until that time is reached

\- \*\*Public or private capsules\*\* — private capsules specify a recipient address; only the sender or recipient can read the message once unlocked, enforced by the contract

\- \*\*On-chain achievement badges\*\* — earn badges for creating your first capsule, locking one for a year+, reaching 10 capsules, or being among the platform's first 20 capsules

\- \*\*No wallet required to read\*\* — capsule data is public on-chain data; anyone can browse unlocked messages without connecting a wallet. A wallet is only needed to create a new capsule

\- \*\*One-click network setup\*\* — a button adds Arc Testnet to MetaMask automatically, with the correct RPC, chain ID, and explorer pre-filled



\## Tech stack



\- \*\*Contract:\*\* Solidity `^0.8.24`, deployed with \[Hardhat](https://hardhat.org)

\- \*\*Frontend:\*\* Single-file HTML/CSS/JS, \[ethers.js v6](https://docs.ethers.org/v6/) for chain interaction — no build step

\- \*\*Network:\*\* \[Arc Testnet](https://testnet.arcscan.app) (Chain ID `5042002`), gas paid in testnet USDC



\## Project structure## Running it locally



```bash

npm install

cp .env.example .env

\# add your testnet wallet's private key to .env



npm run compile

npm run deploy        # deploys to Arc Testnet, prints the contract address



\# paste the deployed address into frontend/index.html (CONTRACT\_ADDRESS)

cd frontend

npx serve             # open http://localhost:3000

```



You'll need testnet USDC for gas — get some free from the \[Circle faucet](https://faucet.circle.com).



\## How the lock actually works



The message is written to contract storage when a capsule is created — but `getMessage(id)` is a `view` function that checks `block.timestamp >= unlockTime` before returning anything, and for private capsules additionally checks that the caller is the sender or recipient. This is enforced by the EVM itself, not just hidden in the UI.



One honest caveat: raw contract storage is technically inspectable off-chain by anyone running their own node or indexer — true cryptographic secrecy isn't possible with plaintext on a public chain. For this project's purposes (an on-chain time capsule demo), a contract-level access gate is the right tradeoff; a production version handling sensitive data would encrypt the message client-side before storing it.



\## Deployed contract



Arc Testnet: \[`0xA5625c2876D0D9E8737438E2833493AAb93cFEb1`](https://testnet.arcscan.app/address/0xA5625c2876D0D9E8737438E2833493AAb93cFEb1)



\## Disclaimer



ChronoVault is an independent demo project built on Arc's public testnet. It is not affiliated with or endorsed by Circle or Arc. Testnet assets have no real-world value.

