# BIP39
[![Build Status](https://travis-ci.org/pengpengliu/BIP39.svg)](https://travis-ci.org/pengpengliu/BIP39) 
[![codecov](https://codecov.io/gh/pengpengliu/BIP39/branch/master/graph/badge.svg)](https://codecov.io/gh/pengpengliu/BIP39)

Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

```swift
// Generating the mnemonic, defaults to english wordlist and 128-bits of entropy
let random = try Mnemonic()

// Initialize with seed phrase and passphrase
let mnemonic = try Mnemonic(phrase: "rally speed budget undo purpose orchard hero news crunch flush wine finger".components(separatedBy: " "), passphrase: "")

// From mnemonic to seed
let seed = try mnemonic.seed()

// Non-english or custom wordlists must be passed to the conversion and validation APIs consistently
let entropy = [UInt8](repeating: 0, count: 16)
let chinesePhrase = try Mnemonic.toMnemonic(entropy, wordlist: Wordlists.chinese)
let chineseMnemonic = try Mnemonic(phrase: chinesePhrase, passphrase: "", wordlist: Wordlists.chinese)
```

`Mnemonic(strength:)`, `Mnemonic(phrase:)`, `Mnemonic.toMnemonic(_:)`, `Mnemonic.toEntropy(_:)`, and `Mnemonic.seed()` can throw when entropy, mnemonic, wordlist, random bytes generation, or key derivation fails.

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
