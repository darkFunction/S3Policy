@testable import S3Policy
import XCTest

final class S3PolicyTests: XCTestCase {
    
    func testEncoding() {
        let t = S3Policy(
            expiration: Date(timeIntervalSince1970: 0),
            conditions: [
                .exact(.bucket, "s3-bucket"),
                .exact(.key, "UUID"),
                .exact(.acl, "private"),
                .exact(.successActionRedirect, "http://localhost/"),
                .startsWith(.contentType, "image/"),
                .contentLength(0...5242880)
            ])

        let encoder = JSONEncoder()
        let data = try! encoder.encode(t)
        
        let expectedOutput = """
            {
              "conditions": [
                {"bucket": "s3-bucket"},
                {"key": "UUID"},
                {"acl": "private"},
                {"success_action_redirect": "http:\\/\\/localhost\\/"},
                ["starts-with", "$Content-Type", "image\\/"],
                ["content-length-range", 0, 5242880]
              ],
              "expiration": "1970-01-01T00:00:00Z"
            }
        """.stringByRemovingWhitespaces

        XCTAssertEqual(String(data: data, encoding: .utf8), expectedOutput)
        XCTAssert(true)
    }
    
    static let allTests = [
        ("testEncoding", testEncoding)
    ]
}

extension String {
    var stringByRemovingWhitespaces: String {
        let split = components(separatedBy: .whitespacesAndNewlines)
        return split.joined(separator: "")
    }
}

