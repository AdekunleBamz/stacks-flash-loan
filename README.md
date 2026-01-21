# Stacks Flash Loans

A secure flash loan implementation for the Stacks blockchain, enabling uncollateralized borrowing within a single transaction with automatic repayment verification.

## Overview

Flash loans allow borrowing assets without collateral, provided the borrowed amount plus fees is returned within the same transaction. This DeFi primitive enables arbitrage, liquidation, and other complex financial operations.

**Key Features:**
- **STX Flash Loans**: Borrow STX tokens with 0.5% fee
- **SIP-010 Token Support**: Borrow any SIP-010 compliant token with 1% fee
- **Atomic Execution**: Borrow and repay in a single transaction
- **Trait-Based Callbacks**: Secure callback mechanism for borrower logic
- **Automatic Verification**: Contract ensures repayment before transaction completes

## How Flash Loans Work

1. **Borrow**: Contract lends assets to a borrower contract
2. **Execute**: Borrower performs operations (arbitrage, liquidation, etc.)
3. **Repay**: Borrower returns borrowed amount + fee to the lender
4. **Verify**: Contract checks repayment was received

If repayment fails, the entire transaction reverts.

## Architecture

### Core Contracts

- **`flasher.clar`**: Main flash loan contract implementing lending logic
- **`flashloans-trait.clar`**: Traits defining borrower contract interfaces
- **`mock-flash-recipient.clar`**: Example borrower contract implementation
- **`mock-token.clar`**: Mock SIP-010 token for testing

### Contract Interfaces

#### STX Flash Borrower
```clarity
(define-trait stx-flasher
  ((on-stx-flash (uint uint) (response bool uint)))
)
```

#### SIP-010 Flash Borrower
```clarity
(define-trait sip010-flasher
  ((on-sip010-flash (<ft-trait> uint uint) (response bool uint)))
)
```

## Usage Examples

### Basic STX Flash Loan

```clarity
;; Borrower contract implementing stx-flasher trait
(define-public (on-stx-flash (amount uint) (return-amount uint))
  ;; Perform arbitrage, liquidation, or other logic
  ;; Must return (ok true) and repay return-amount to flasher contract
  (ok true)
)

;; Execute flash loan
(contract-call? .flasher flash-stx amount borrower-contract)
```

### SIP-010 Token Flash Loan

```clarity
;; Borrower contract implementing sip010-flasher trait
(define-public (on-sip010-flash (token <ft-trait>) (amount uint) (return-amount uint))
  ;; Use token for operations
  ;; Must return (ok true) and repay return-amount tokens to flasher contract
  (ok true)
)

;; Execute token flash loan
(contract-call? .flasher flash-sip010 token-contract amount borrower-contract)
```

## Fee Structure

- **STX Flash Loans**: 0.5% fee (5000 pips)
- **SIP-010 Flash Loans**: 1% fee (10000 pips)

Fees are calculated as: `amount * fee_pips / 1,000,000`

## Security Features

### Automatic Repayment Verification
- Contract tracks balances before and after flash loan
- Ensures exact repayment amount is received
- Transaction reverts if repayment insufficient

### Trait-Based Callbacks
- Borrower contracts must implement specific traits
- Prevents unauthorized contract interactions
- Type-safe callback interfaces

### Balance Validation
- Checks sufficient funds before lending
- Validates all token transfers succeed
- Comprehensive error handling

## Testing

```bash
npm install
npm test
```

Continuous integration: The test suite runs on pushes and pull requests to `master` via `.github/workflows/ci.yml`.

Tests cover:
- Successful flash loans with repayment
- Failed loans due to insufficient repayment
- Invalid borrower contracts
- Balance validation

## Deployment

### Testnet Deployment

```bash
clarinet deployments generate --testnet
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

### Mainnet Deployment

```bash
clarinet deployments generate --mainnet
clarinet deployments apply -p deployments/default.mainnet-plan.yaml
```

## Borrower Contract Example

```clarity
;; Example arbitrage contract
(define-public (on-stx-flash (amount uint) (return-amount uint))
  ;; Execute arbitrage logic here
  ;; e.g., swap STX for cheaper token on DEX A
  ;; then swap back on DEX B for profit

  ;; Transfer repayment back to flasher
  (try! (stx-transfer? return-amount tx-sender (contract-of .flasher)))

  (ok true)
)
```

## Error Codes

| Code | Error | Description |
|------|--------|-------------|
| 101 | ERR_INSUFFICIENT_BALANCE | Insufficient funds for flash loan |
| 102 | ERR_OUTBOUND_TRANFER_FAILED | Failed to send tokens to borrower |
| 103 | ERR_FLASHER_CALLBACK_FAILED | Borrower callback failed |
| 104 | ERR_INBOUND_TRANFER_FAILED | Failed to receive repayment |
| 105 | ERR_INSUFFICIENT_PAYBACK | Repayment amount insufficient |
| 106 | ERR_FAILED_TO_FETCH_BALANCE | Could not fetch token balance |

## Use Cases

- **Arbitrage**: Exploit price differences across DEXs
- **Liquidation**: Liquidate undercollateralized positions
- **Collateral Swap**: Change collateral type in lending protocols
- **Self-Liquidation**: Avoid bad debt in lending pools
- **Complex DeFi Operations**: Multi-step financial transactions

## Limitations

- **Single Transaction**: All operations must complete in one transaction
- **Fee Requirements**: Borrower must account for and pay fees
- **Contract Calls Only**: Borrower must be a contract implementing traits
- **Balance Checks**: Strict balance verification prevents underpayment

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Resources

- [Stacks Documentation](https://docs.stacks.co)
- [Clarity Language Reference](https://docs.stacks.co/docs/clarity)
- [SIP-010 Token Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)
- [Flash Loans Explained](https://docs.aave.com/developers/guides/flash-loans)

## License

[Add your license information]
