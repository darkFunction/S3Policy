import XCTest

import S3PolicyTests

var tests = [XCTestCaseEntry]()
tests += S3PolicyTests.allTests()
XCTMain(tests)