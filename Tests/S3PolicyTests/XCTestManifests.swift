import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(S3PolicyTests.allTests),
    ]
}
#endif