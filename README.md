# BIP39
[![Build Status](https://travis-ci.org/pengpengliu/BIP39.svg)](https://travis-ci.org/pengpengliu/BIP39) 
[![codecov](https://codecov.io/gh/pengpengliu/BIP39/branch/master/graph/badge.svg)](https://codecov.io/gh/pengpengliu/BIP39)

Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). [#PureSwift](https://twitter.com/hashtag/pureswift)

```swift
// Generating the mnemonic, defaults to english wordlist and 128-bits of entropy
let random = Mnemonic()

// Initialize with seed phrase and passphrase
let mnemonic = Mnemonic(phrase: "A wallet is an application that handles your secret key to help send signed messages to the network to manage your account. It helps you send/receive transactions and change your representative.".components(separatedBy: " "), passphrase: "")

// From mnemonic to seed
let seed = mnemonic.seed
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
