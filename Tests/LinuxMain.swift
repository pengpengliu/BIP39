import XCTest

import BIP39Tests

var tests = [XCTestCaseEntry]()
tests += BIP39Tests.allTests()
XCTMain(tests)
