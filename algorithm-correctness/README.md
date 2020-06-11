# Formalization and Correctness Proof of Incremental Merkle Tree Algorithm of Deposit Contract

Our formalization of the [incremental Merkle tree algorithm], especially the one employed in the [deposit contract], and its correctness proof w.r.t. the [original full-construction Merkle tree algorithm] can be found in [the final report](../deposit-formal-verification.pdf).

The correctness proof presented in the report has also been mechanized in K:
 * [deposit.k](deposit.k): Formal model of the incremental Merkle tree algorithm
 * [deposit-spec.k](deposit-spec.k): Correctness specifications
 * [deposit-symbolic.k](deposit-symbolic.k): Lemmas (trusted)

To run the mechanized proof:
```
$ ./run.sh
```

Prerequisites:
 * Install K: https://github.com/kframework/k/releases

## [Resources]

## [Disclaimer]

[deposit contract]: <https://github.com/ethereum/eth2.0-specs/tree/master/deposit_contract>
[incremental Merkle tree algorithm]: <https://github.com/ethereum/research/blob/master/beacon_chain_impl/progressive_merkle_tree.py>
[original full-construction Merkle tree algorithm]: <https://en.wikipedia.org/wiki/Merkle_tree>

[Resources]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/README.md#resources>
[Disclaimer]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/README.md#disclaimer>
