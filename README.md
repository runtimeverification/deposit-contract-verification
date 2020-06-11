*2020-06-10*

# End-to-End Formal Verification of Ethereum 2.0 Deposit Contract

This provides the artifact of our end-to-end formal verification of the Ethereum 2.0 [deposit contract] written in Solidity.

_[NOTE: The deposit contract had initially been written in Vyper, but later it was reimplemented
in Solidity. The formal verification of the initial Vyper implementation can be found at [here](https://github.com/runtimeverification/verified-smart-contracts/tree/master/deposit)]._

Documents:
 * Final report: [`deposit-contract-verification.pdf`](deposit-contract-verification.pdf)
 * Blog posts:
   * [Formal Verification of Ethereum 2.0 Deposit Contract (Part I)](https://runtimeverification.com/blog/formal-verification-of-ethereum-2-0-deposit-contract-part-1/) (June 12, 2019)
   * [End-to-End Formal Verification of Ethereum 2.0 Deposit Smart Contract](https://runtimeverification.com/blog/end-to-end-formal-verification-of-ethereum-2-0-deposit-smart-contract/) (January 20, 2020)

Verification artifacts:
 * [`algorithm-correctness/`](algorithm-correctness): Formalization and correctness proof of incremental Merkle tree algorithm
 * [`bytecode-verification/`](bytecode-verification): Bytecode verification of the deposit contract

## [Resources]

## [Disclaimer]

## [License]

[deposit contract]: <https://github.com/ethereum/eth2.0-specs/tree/master/deposit_contract>

[Resources]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/README.md#resources>
[Disclaimer]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/README.md#disclaimer>
[License]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/README.md#license>
