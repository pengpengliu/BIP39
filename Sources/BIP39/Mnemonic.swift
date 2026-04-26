//
//  Mnemonic.swift
//
//  See BIP39 specification for more info:
//  https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
//
//  Created by Liu Pengpeng on 2019/10/10.
//

import Foundation
import CryptoKit

public class Mnemonic {
    public enum Error: Swift.Error, Equatable {
        case invalidMnemonic
        case invalidEntropy
        case invalidWordlist
        case randomBytesGenerationFailed
    }
    
    public let phrase: [String]
    let passphrase: String
    
    private static let validStrengths: Set<Int> = [128, 160, 192, 224, 256]
    private static let validEntropyByteCounts: Set<Int> = [16, 20, 24, 28, 32]
    private static let validPhraseWordCounts: Set<Int> = [12, 15, 18, 21, 24]
    private static let wordlistSize = 2048
    
    public init(strength: Int = 128, wordlist: [String] = Wordlists.english) throws {
        try Mnemonic.validateStrength(strength)
        try Mnemonic.validateWordlist(wordlist)
        
        // 1.Random Bytes
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            throw Error.randomBytesGenerationFailed
        }
        
        // 2.Entropy -> Mnemonic
        self.phrase = try Mnemonic.toMnemonic(bytes, wordlist: wordlist)
        self.passphrase = ""
    }
    
    public init(phrase: [String], passphrase: String = "", wordlist: [String] = Wordlists.english) throws {
        _ = try Mnemonic.toEntropy(phrase, wordlist: wordlist)
        self.phrase = phrase
        self.passphrase = passphrase
    }
    
    public init(entropy: [UInt8], wordlist: [String] = Wordlists.english) throws {
        self.phrase = try Mnemonic.toMnemonic(entropy, wordlist: wordlist)
        self.passphrase = ""
    }
    
    // Entropy -> Mnemonic
    public static func toMnemonic(_ bytes: [UInt8], wordlist: [String] = Wordlists.english) throws -> [String] {
        try validateEntropy(bytes)
        try validateWordlist(wordlist)
        
        let entropyBits = bytes.map { binaryString(Int($0), width: 8) }.joined()
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits
        
        var phrase = [String]()
        for i in 0..<(bits.count / 11) {
            let start = bits.index(bits.startIndex, offsetBy: i * 11)
            let end = bits.index(bits.startIndex, offsetBy: (i + 1) * 11)
            guard let wi = Int(String(bits[start..<end]), radix: 2), wi < wordlist.count else {
                throw Error.invalidMnemonic
            }
            phrase.append(String(wordlist[wi]))
        }
        return phrase
    }
    
    // Mnemonic -> Entropy
    public static func toEntropy(_ phrase: [String], wordlist: [String] = Wordlists.english) throws -> [UInt8] {
        try validateWordlist(wordlist)
        try validatePhraseLength(phrase)
        
        var bits = ""
        for word in phrase {
            guard let index = wordlist.firstIndex(of: word) else {
                throw Error.invalidMnemonic
            }
            bits += binaryString(index, width: 11)
        }
        
        let dividerIndex = bits.count / 33 * 32
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))
        
        let entropyBytes = try bytes(fromBits: entropyBits)
        if (checksumBits != Mnemonic.deriveChecksumBits(entropyBytes)) {
            throw Error.invalidMnemonic
        }
        return entropyBytes
    }
    
    public static func isValid(phrase: [String], wordlist: [String] = Wordlists.english) -> Bool {
        return (try? toEntropy(phrase, wordlist: wordlist)) != nil
    }
    
    public static func deriveChecksumBits(_ bytes: [UInt8]) -> String {
        let ENT = bytes.count * 8;
        let CS = ENT / 32
        
        let hash = SHA256.hash(data: bytes)
        let hashbits = hash.map { binaryString(Int($0), width: 8) }.joined()
        return String(hashbits.prefix(CS))
    }
    
    public func seed() throws -> [UInt8] {
        let mnemonic = Mnemonic.nfkd(self.phrase.joined(separator: " "))
        let salt = Mnemonic.nfkd("mnemonic" + self.passphrase)
        return try PKCS5.PBKDF2SHA512(password: mnemonic, salt: salt)
    }
    
    private static func validateStrength(_ strength: Int) throws {
        guard validStrengths.contains(strength) else {
            throw Error.invalidEntropy
        }
    }
    
    private static func validateEntropy(_ bytes: [UInt8]) throws {
        guard validEntropyByteCounts.contains(bytes.count) else {
            throw Error.invalidEntropy
        }
    }
    
    private static func validatePhraseLength(_ phrase: [String]) throws {
        guard validPhraseWordCounts.contains(phrase.count) else {
            throw Error.invalidMnemonic
        }
    }
    
    private static func validateWordlist(_ wordlist: [String]) throws {
        guard wordlist.count == wordlistSize, Set(wordlist).count == wordlistSize else {
            throw Error.invalidWordlist
        }
    }
    
    private static func binaryString(_ value: Int, width: Int) -> String {
        let bits = String(value, radix: 2)
        if bits.count >= width {
            return bits
        }
        return String(repeating: "0", count: width - bits.count) + bits
    }
    
    private static func bytes(fromBits bits: String) throws -> [UInt8] {
        guard bits.count % 8 == 0 else {
            throw Error.invalidMnemonic
        }
        
        var bytes = [UInt8]()
        var index = bits.startIndex
        while index < bits.endIndex {
            let nextIndex = bits.index(index, offsetBy: 8)
            guard let byte = UInt8(String(bits[index..<nextIndex]), radix: 2) else {
                throw Error.invalidMnemonic
            }
            bytes.append(byte)
            index = nextIndex
        }
        return bytes
    }
    
    private static func nfkd(_ string: String) -> String {
        return (string as NSString).decomposedStringWithCompatibilityMapping
    }
}

extension Mnemonic: Equatable {
    public static func == (lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        return lhs.phrase == rhs.phrase && lhs.passphrase == rhs.passphrase
    }
}
