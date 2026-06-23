# BIP39

[English](README.md) | **简体中文**

[![Swift](https://img.shields.io/badge/Swift-5.1+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS-lightgrey.svg)](https://developer.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](LICENSE.txt)

比特币 [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) 助记词生成、校验、熵转换以及种子派生的 Swift 实现。

## 环境要求

- Swift 5.1+
- macOS 10.15+ 或 iOS 13+
- Swift Package Manager

## 安装

在 `Package.swift` 中添加该依赖包：

```swift
.package(url: "https://github.com/pengpengliu/BIP39.git", branch: "master")
```

然后将 `BIP39` 添加到目标的依赖中：

```swift
.target(
    name: "YourTarget",
    dependencies: ["BIP39"]
)
```

## 使用方法

使用安全的系统随机数生成助记词：

```swift
import BIP39

let mnemonic = try Mnemonic()
print(mnemonic.phrase.joined(separator: " "))
```

使用指定的熵强度：

```swift
let mnemonic = try Mnemonic(strength: 256)
```

支持的强度为 `128`、`160`、`192`、`224` 和 `256` 位，分别对应 `12`、`15`、`18`、`21` 和 `24` 个单词。

从已有的助记词创建并派生 BIP39 种子：

```swift
let words = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    .split(separator: " ")
    .map(String.init)

let mnemonic = try Mnemonic(phrase: words, passphrase: "TREZOR")
let seed = try mnemonic.seed()
```

在熵和助记词之间互相转换：

```swift
let entropy = [UInt8](repeating: 0, count: 16)
let phrase = try Mnemonic.toMnemonic(entropy)
let restoredEntropy = try Mnemonic.toEntropy(phrase)
```

校验助记词：

```swift
if Mnemonic.isValid(phrase: words) {
    // 助记词的单词数量、单词内容和校验和均有效
}
```

## 词表

该包内置了英文和中文词表：

```swift
let entropy = [UInt8](repeating: 0, count: 16)
let phrase = try Mnemonic.toMnemonic(entropy, wordlist: Wordlists.chinese)
let mnemonic = try Mnemonic(phrase: phrase, passphrase: "", wordlist: Wordlists.chinese)
```

使用非英文或自定义词表时，请在所有转换、校验和初始化 API 中传入相同的词表。自定义词表必须恰好包含 2048 个互不相同的单词。

## API 说明

`Mnemonic` 采用严格的 BIP39 校验：

- 熵必须为 `16`、`20`、`24`、`28` 或 `32` 字节
- 助记词长度必须为 `12`、`15`、`18`、`21` 或 `24` 个单词
- 词表必须恰好包含 2048 个互不相同的单词
- 种子派生在 PBKDF2-HMAC-SHA512 之前会应用 BIP39 NFKD 规范化
- 若安全的系统随机数生成失败，则随机助记词生成也会失败

以下 API 在输入无效或派生失败时会抛出异常：

- `try Mnemonic(strength:wordlist:)`
- `try Mnemonic(phrase:passphrase:wordlist:)`
- `try Mnemonic(entropy:wordlist:)`
- `try Mnemonic.toMnemonic(_:wordlist:)`
- `try Mnemonic.toEntropy(_:wordlist:)`
- `try mnemonic.seed()`

## 测试

运行测试套件：

```sh
swift test
```

测试涵盖官方 BIP39 测试向量、熵边界、校验和验证、Unicode 规范化、中文词表往返转换、无效词表以及 PBKDF2 输入校验。

## 许可证

代码采用 [BSD 2-clause "Simplified" 许可证](LICENSE.txt)。
文档采用 [Creative Commons Attribution 许可证](https://creativecommons.org/licenses/by/4.0/)。
