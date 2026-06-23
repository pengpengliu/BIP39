# BIP39

**English** | [简体中文](README.zh-CN.md)

[![Swift](https://img.shields.io/badge/Swift-5.1+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS-lightgrey.svg)](https://developer.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](LICENSE.txt)

Swift implementation of Bitcoin [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) mnemonic generation, validation, entropy conversion, and seed derivation.

## Requirements

- Swift 5.1+
- macOS 10.15+ or iOS 13+
- Swift Package Manager

## Installation

Add the package to `Package.swift`:

```swift
.package(url: "https://github.com/pengpengliu/BIP39.git", branch: "master")
```

Then add `BIP39` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["BIP39"]
)
```

## Usage

Generate a mnemonic with secure system randomness:

```swift
import BIP39

let mnemonic = try Mnemonic()
print(mnemonic.phrase.joined(separator: " "))
```

Use a specific entropy strength:

```swift
let mnemonic = try Mnemonic(strength: 256)
```

Supported strengths are `128`, `160`, `192`, `224`, and `256` bits, which produce `12`, `15`, `18`, `21`, and `24` words.

Create a mnemonic from an existing phrase and derive the BIP39 seed:

```swift
let words = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    .split(separator: " ")
    .map(String.init)

let mnemonic = try Mnemonic(phrase: words, passphrase: "TREZOR")
let seed = try mnemonic.seed()
```

Convert between entropy and mnemonic words:

```swift
let entropy = [UInt8](repeating: 0, count: 16)
let phrase = try Mnemonic.toMnemonic(entropy)
let restoredEntropy = try Mnemonic.toEntropy(phrase)
```

Validate a phrase:

```swift
if Mnemonic.isValid(phrase: words) {
    // phrase has a valid word count, words, and checksum
}
```

## Wordlists

The package includes English and Chinese wordlists:

```swift
let entropy = [UInt8](repeating: 0, count: 16)
let phrase = try Mnemonic.toMnemonic(entropy, wordlist: Wordlists.chinese)
let mnemonic = try Mnemonic(phrase: phrase, passphrase: "", wordlist: Wordlists.chinese)
```

When using a non-English or custom wordlist, pass the same wordlist to every conversion, validation, and initialization API. Custom wordlists must contain exactly 2048 unique words.

## API Notes

`Mnemonic` uses strict BIP39 validation:

- entropy must be `16`, `20`, `24`, `28`, or `32` bytes
- phrase length must be `12`, `15`, `18`, `21`, or `24` words
- wordlists must contain exactly 2048 unique words
- seed derivation applies BIP39 NFKD normalization before PBKDF2-HMAC-SHA512
- random mnemonic generation fails if secure system randomness fails

These APIs throw on invalid input or derivation failure:

- `try Mnemonic(strength:wordlist:)`
- `try Mnemonic(phrase:passphrase:wordlist:)`
- `try Mnemonic(entropy:wordlist:)`
- `try Mnemonic.toMnemonic(_:wordlist:)`
- `try Mnemonic.toEntropy(_:wordlist:)`
- `try mnemonic.seed()`

## Testing

Run the test suite:

```sh
swift test
```

Tests cover official BIP39 vectors, entropy boundaries, checksum validation, Unicode normalization, Chinese wordlist round-trips, invalid wordlists, and PBKDF2 input validation.

## License

Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
