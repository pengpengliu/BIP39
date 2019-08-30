# BIP39
Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). [#PureSwift](https://twitter.com/hashtag/pureswift)

## Requirements
* Xcode 11.0
* Swift 5.0

## Getting Started

```swift
import BIP39

// Generate a random mnemonic, defaults to english wordlist and 128-bits of entropy
let random = Mnemonic()

// Initialize with seed phrase and passphrase
let mnemonic = Mnemonic(phrase: "rally speed budget undo purpose orchard hero news crunch flush wine finger".components(separatedBy: " "), passphrase: "")
let seed = mnemonic.seed
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).