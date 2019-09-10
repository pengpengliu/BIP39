# BIP39
[![Build Status](https://travis-ci.org/pengpengliu/BIP39.svg)](https://travis-ci.org/pengpengliu/BIP39) 
[![codecov](https://codecov.io/gh/pengpengliu/BIP39/branch/master/graph/badge.svg)](https://codecov.io/gh/pengpengliu/BIP39)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). [#PureSwift](https://twitter.com/hashtag/pureswift)

## Requirements
* Xcode 11.0
* Swift 5.0

## Getting Started

You can just drop `Mnemonic.swift` `Wordlists.swift` `PKCS5.swift` into your project.

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
