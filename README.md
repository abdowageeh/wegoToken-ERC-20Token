# WegoToken (WT3)

A customizable ERC-20 token smart contract built with **Solidity**, **OpenZeppelin**, and **Foundry**.

WegoToken implements the ERC-20 standard and provides owner-controlled token minting, ownership management, and comprehensive automated testing.

## Overview

This project demonstrates the implementation and testing of an ERC-20 token using industry-standard Solidity libraries.

It uses OpenZeppelin for secure, reusable token and access-control functionality and Foundry for compilation and automated testing.

## Features

- ERC-20 standard token functionality.
- Custom token name and symbol.
- Owner-only token minting.
- Secure access control using OpenZeppelin `Ownable`.
- Ownership transfer.
- Ownership renunciation.
- Standard token transfers.
- Token approvals and allowances.
- Delegated transfers using `transferFrom`.
- Automated unit tests using Foundry.
- Revert-condition and event-emission testing.

## Tech Stack

- **Solidity** — Smart contract development.
- **OpenZeppelin** — ERC-20 and ownership implementations.
- **Foundry** — Smart contract development and testing.
- **Forge** — Compilation and test execution.

## Token Details

| Property | Value |
|---|---|
| Token Name | WegoToken |
| Token Symbol | WT3 |
| Standard | ERC-20 |
| Solidity Version | ^0.8.31 |
| Decimals | 18 |
| Initial Supply | 0 |
| Minting Permission | Contract owner only |

## Smart Contract

The `WegoToken` contract inherits from OpenZeppelin's `ERC20` and `Ownable` contracts.

### Constructor

The constructor initializes the token name and symbol and assigns ownership to the deployer's address.

```solidity
constructor(string memory name, string memory symbol)
    ERC20(name, symbol)
    Ownable(msg.sender)
{
}
```

### Mint Function

The `mint` function allows the owner to create new tokens and send them to a specified address.

```solidity
function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
}
```

The `onlyOwner` modifier prevents unauthorized accounts from minting tokens.

The contract does not currently enforce a maximum supply.

## Testing

The project includes automated tests covering the following areas:

### Constructor Tests
- Token name and symbol.
- Initial owner.
- Initial total supply.
- Default decimals.

### Minting Tests
- Successful minting by the owner.
- Minting to multiple addresses.
- Rejection of unauthorized minting.
- Rejection of the zero address.

### Transfer Tests
- Successful token transfers.
- Balance updates.
- Insufficient balance errors.
- Invalid recipient errors.
- `Transfer` event emission.

### Approval Tests
- Successful approvals.
- Allowance updates and overwrites.
- Invalid spender rejection.
- `Approval` event emission.

### TransferFrom Tests
- Successful delegated transfers.
- Allowance reduction.
- Insufficient allowance errors.
- Infinite allowance behavior.
- Invalid recipient rejection.

### Ownership Tests
- Successful ownership transfer.
- Unauthorized ownership transfer rejection.
- Zero-address ownership rejection.
- Minting permissions after ownership transfer.
- Ownership renunciation and minting restrictions.

## Security Considerations

- Only the current owner can mint new tokens.
- The token supply is not capped.
- Renouncing ownership permanently disables owner-only minting.
- Automated tests help verify expected behavior but do not guarantee complete security.

A production deployment should undergo additional testing and a security review.

## Future Improvements

- Add a maximum token supply.
- Implement token burning.
- Add pause and unpause functionality.
- Create deployment scripts.
- Deploy to an Ethereum testnet.
- Integrate with a frontend using `wagmi`, `viem`, or `ethers.js`.