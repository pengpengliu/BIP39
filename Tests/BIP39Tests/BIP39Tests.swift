import XCTest
@testable import BIP39

final class BIP39Tests: XCTestCase {
    private let officialEntropy = "00000000000000000000000000000000"
    private let officialMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    private let officialSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
    
    func testWordlistSizes() {
        XCTAssertEqual(Wordlists.english.count, 2048)
        XCTAssertEqual(Wordlists.chinese.count, 2048)
    }
    
    func testRandomMnemonicUsesRequestedStrength() throws {
        let mnemonic = try Mnemonic(strength: 256)
        
        XCTAssertEqual(mnemonic.phrase.count, 24)
        XCTAssertTrue(Mnemonic.isValid(phrase: mnemonic.phrase))
    }
    
    func testOfficialEnglishVector() throws {
        let entropy = bytes(fromHex: officialEntropy)
        let phrase = try Mnemonic.toMnemonic(entropy)
        let mnemonic = try Mnemonic(phrase: phrase, passphrase: "TREZOR")
        
        XCTAssertEqual(phrase.joined(separator: " "), officialMnemonic)
        XCTAssertEqual(try Mnemonic.toEntropy(phrase), entropy)
        XCTAssertEqual(hexString(try mnemonic.seed()), officialSeed)
    }
    
    func testValidEntropyLengths() throws {
        let cases = [
            (byteCount: 16, wordCount: 12),
            (byteCount: 20, wordCount: 15),
            (byteCount: 24, wordCount: 18),
            (byteCount: 28, wordCount: 21),
            (byteCount: 32, wordCount: 24),
        ]
        
        for testCase in cases {
            let entropy = [UInt8](repeating: UInt8(testCase.byteCount), count: testCase.byteCount)
            let phrase = try Mnemonic.toMnemonic(entropy)
            
            XCTAssertEqual(phrase.count, testCase.wordCount)
            XCTAssertEqual(try Mnemonic.toEntropy(phrase), entropy)
            XCTAssertTrue(Mnemonic.isValid(phrase: phrase))
        }
    }
    
    func testInvalidEntropyAndPhraseLengths() {
        XCTAssertThrowsMnemonicError(try Mnemonic(strength: 96), .invalidEntropy)
        XCTAssertThrowsMnemonicError(try Mnemonic.toMnemonic([]), .invalidEntropy)
        XCTAssertThrowsMnemonicError(try Mnemonic.toMnemonic([0]), .invalidEntropy)
        XCTAssertThrowsMnemonicError(try Mnemonic.toEntropy([]), .invalidMnemonic)
        XCTAssertThrowsMnemonicError(try Mnemonic.toEntropy(Array(repeating: "abandon", count: 9)), .invalidMnemonic)
        
        XCTAssertFalse(Mnemonic.isValid(phrase: []))
        XCTAssertFalse(Mnemonic.isValid(phrase: Array(repeating: "abandon", count: 9)))
    }
    
    func testInvalidMnemonicThrowsInsteadOfCrashing() {
        let invalidWordPhrase = Array(repeating: "abandon", count: 11) + ["notaword"]
        let invalidChecksumPhrase = Array(repeating: "abandon", count: 12)
        
        XCTAssertThrowsMnemonicError(try Mnemonic.toEntropy(invalidWordPhrase), .invalidMnemonic)
        XCTAssertThrowsMnemonicError(try Mnemonic.toEntropy(invalidChecksumPhrase), .invalidMnemonic)
        XCTAssertThrowsMnemonicError(try Mnemonic(phrase: invalidWordPhrase), .invalidMnemonic)
        
        XCTAssertFalse(Mnemonic.isValid(phrase: invalidWordPhrase))
        XCTAssertFalse(Mnemonic.isValid(phrase: invalidChecksumPhrase))
    }
    
    func testNFKDPassphraseNormalization() throws {
        let phrase = officialMnemonic.components(separatedBy: " ")
        let composed = try Mnemonic(phrase: phrase, passphrase: "é")
        let decomposed = try Mnemonic(phrase: phrase, passphrase: "e\u{301}")
        
        XCTAssertEqual(try composed.seed(), try decomposed.seed())
    }
    
    func testChineseWordlistRoundTrip() throws {
        let entropy = bytes(fromHex: officialEntropy)
        let phrase = try Mnemonic.toMnemonic(entropy, wordlist: Wordlists.chinese)
        let mnemonic = try Mnemonic(phrase: phrase, passphrase: "", wordlist: Wordlists.chinese)
        
        XCTAssertEqual(mnemonic.phrase, phrase)
        XCTAssertEqual(try Mnemonic.toEntropy(phrase, wordlist: Wordlists.chinese), entropy)
        XCTAssertTrue(Mnemonic.isValid(phrase: phrase, wordlist: Wordlists.chinese))
        XCTAssertFalse(Mnemonic.isValid(phrase: phrase))
    }
    
    func testInvalidWordlist() {
        let entropy = bytes(fromHex: officialEntropy)
        let phrase = officialMnemonic.components(separatedBy: " ")
        var shortWordlist = Wordlists.english
        shortWordlist.removeLast()
        var duplicateWordlist = Wordlists.english
        duplicateWordlist[1] = duplicateWordlist[0]
        
        XCTAssertThrowsMnemonicError(try Mnemonic.toMnemonic(entropy, wordlist: shortWordlist), .invalidWordlist)
        XCTAssertThrowsMnemonicError(try Mnemonic.toEntropy(phrase, wordlist: duplicateWordlist), .invalidWordlist)
        XCTAssertThrowsMnemonicError(try Mnemonic(phrase: phrase, wordlist: duplicateWordlist), .invalidWordlist)
        
        XCTAssertFalse(Mnemonic.isValid(phrase: phrase, wordlist: shortWordlist))
        XCTAssertFalse(Mnemonic.isValid(phrase: phrase, wordlist: duplicateWordlist))
    }
    
    func testInvalidPBKDF2Input() {
        XCTAssertThrowsError(try PKCS5.PBKDF2SHA512(password: "password", salt: "salt", iterations: 0))
        XCTAssertThrowsError(try PKCS5.PBKDF2SHA512(password: "password", salt: "salt", keyLength: 0))
    }

    static var allTests = [
        ("testWordlistSizes", testWordlistSizes),
        ("testRandomMnemonicUsesRequestedStrength", testRandomMnemonicUsesRequestedStrength),
        ("testOfficialEnglishVector", testOfficialEnglishVector),
        ("testValidEntropyLengths", testValidEntropyLengths),
        ("testInvalidEntropyAndPhraseLengths", testInvalidEntropyAndPhraseLengths),
        ("testInvalidMnemonicThrowsInsteadOfCrashing", testInvalidMnemonicThrowsInsteadOfCrashing),
        ("testNFKDPassphraseNormalization", testNFKDPassphraseNormalization),
        ("testChineseWordlistRoundTrip", testChineseWordlistRoundTrip),
        ("testInvalidWordlist", testInvalidWordlist),
        ("testInvalidPBKDF2Input", testInvalidPBKDF2Input),
    ]
    
    private func XCTAssertThrowsMnemonicError<T>(
        _ expression: @autoclosure () throws -> T,
        _ expectedError: Mnemonic.Error,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            _ = try expression()
            XCTFail("Expected Mnemonic.Error.\(expectedError)", file: file, line: line)
        } catch let error as Mnemonic.Error {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
    
    private func bytes(fromHex hex: String) -> [UInt8] {
        var bytes = [UInt8]()
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            bytes.append(UInt8(String(hex[index..<nextIndex]), radix: 16)!)
            index = nextIndex
        }
        return bytes
    }
    
    private func hexString(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}
