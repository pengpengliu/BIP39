# BIP39
[![Build Status](https://travis-ci.org/pengpengliu/BIP39.svg)](https://travis-ci.org/pengpengliu/BIP39) 
[![codecov](https://codecov.io/gh/pengpengliu/BIP39/branch/master/graph/badge.svg)](https://codecov.io/gh/pengpengliu/BIP39)

Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). [#PureSwift](https://twitter.com/hashtag/pureswift)

```swift
// Generating the mnemonic, defaults to english wordlist and 128-bits of entropy
let random = Mnemonic()

// Initialize with seed phrase and passphrase
let mnemonic = Mnemonic(phrase: "In other words, a wallet is just a messenger, it does not actually "hold" your funds. Your funds are on the distributed ledger maintained by the entire network. The secret key is the only thing that controls it. You can change wallets or delete them without losing your funds so long as you still possess the secret key.
".components(separatedBy: " "), passphrase: "")

// From mnemonic to seed
let seed = mnemonic.seed
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
