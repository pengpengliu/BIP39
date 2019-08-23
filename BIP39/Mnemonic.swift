//
//  Mnemonic.swift
//
//  Created by Liu Pengpeng on 2019/8/22.
//  Copyright © 2019 Liu Pengpeng. All rights reserved.
//
//  See BIP39 specification for more info:
//  https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
//

import Foundation
import CryptoKit

public class Mnemonic {
    public enum Error: Swift.Error {
        case invalidMnemonic
        case invalidEntropy
    }
    
    let phrase: [String]
    let passphrase: String
    
    init(strength: Int = 128, wordlist: [String] = Wordlists.english) {
        precondition(strength % 32 != 0, "Invalid entropy")
        
        // 1.Random Bytes
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        // 2.Entropy -> Mnemonic
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix:2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits
        
        var phrase = [String]()
        for i in 0..<(bits.count / 11) {
            let wi = Int(bits[bits.index(bits.startIndex, offsetBy: i * 11)..<bits.index(bits.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            phrase.append(String(wordlist[wi]))
        }
        
        self.phrase = phrase
        self.passphrase = ""
    }
    
    init(phrase: [String], passphrase: String = "") throws {
        if (!Mnemonic.isValid(phrase: phrase)) {
            throw Error.invalidMnemonic
        }
        self.phrase = phrase
        self.passphrase = passphrase
    }
    
    static func isValid(phrase: [String], wordlist: [String] = Wordlists.english) -> Bool {
        var bits = ""
        for word in phrase {
            guard let i = wordlist.firstIndex(of: word) else { return false }
            bits += ("00000000000" + String(i, radix: 2)).suffix(11)
        }
        
        let dividerIndex = bits.count / 33 * 32
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))
        
        let regex = try! NSRegularExpression(pattern: "[01]{1,8}", options: .caseInsensitive)
        let entropyBytes = regex.matches(in: entropyBits, options: [], range: NSRange(location: 0, length: entropyBits.count)).map {
            UInt8(strtoul(String(entropyBits[Range($0.range, in: entropyBits)!]), nil, 2))
        }
        return checksumBits == deriveChecksumBits(entropyBytes)
    }
    
    static func deriveChecksumBits(_ bytes: [UInt8]) -> String {
        let ENT = bytes.count * 8;
        let CS = ENT / 32
        
        let hash = SHA256.hash(data: bytes)
        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix:2)).suffix(8) })
        return String(hashbits.prefix(CS))
    }
    
    public var seed: [UInt8] {
        let mnemonic = self.phrase.joined(separator: " ")
        let salt = ("mnemonic" + self.passphrase)
        return try! PKCS5.PBKDF2SHA512(password: mnemonic, salt: salt)
    }
}

extension Mnemonic: Equatable {
    public static func == (lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        return lhs.phrase == rhs.phrase && lhs.passphrase == rhs.passphrase
    }
}
