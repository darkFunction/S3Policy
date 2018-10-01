import Foundation

public struct S3Policy: Encodable {
    let expiration: String
    let conditions: [S3PolicyCondition]
    
    public init(expiration: Date, conditions: [S3PolicyCondition]) {
        self.expiration = expiration.iso8601().full
        self.conditions = conditions
    }
}

extension S3Policy {
    public func json() throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}

public enum S3PolicyCondition: Encodable {
    case exact(ConditionKey, String)
    case startsWith(ConditionKey, String)
    case contentLength(ClosedRange<Int>)
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .exact(let key, let value):
            var container = encoder.container(keyedBy: type(of: key))
            try container.encode(value, forKey: key)
        case .startsWith(let key, let value):
            var container = encoder.singleValueContainer()
            try container.encode([self.conditionOperation(), "$\(key.rawValue)", value])
        case .contentLength(let value):
            var container = encoder.singleValueContainer()
            let arr: [Primitive] = [.string(self.conditionOperation()), .integer(value.lowerBound), .integer(value.upperBound)]
            try container.encode(arr)
        }
    }
    
    private func conditionOperation() -> String {
        switch self {
        case .startsWith(_, _):
            return "starts-with"
        case .contentLength(_):
            return ConditionKey.contentLengthRange.rawValue
        case .exact(_, _):
            return "eq"
        }
    }
}

public enum ConditionKey: String, CodingKey {
    case acl = "acl"
    case bucket = "bucket"
    case contentLengthRange = "content-length-range"
    case key = "key"
    case successActionRedirect = "success_action_redirect"
    case redirect = "redirect"
    case cacheControl = "Cache-Control"
    case contentType = "Content-Type"
    case contentDisposition = "Content-Disposition"
    case contentEncoding = "Content-Encoding"
    case expires = "Expires"
    case successActionStatus = "success_action_status"
    case xAmzAlgorithm = "x-amz-algorithm"
    case xAmzCredential = "x-amz-credential"
    case xAmzDate = "x-amz-date"
    case xAmzSecurityToken = "x-amz-security-token"
    case xAmzMeta = "x-amz-meta-*"
    case xAmz = "x-amz-*"
}

public enum SigningAlgorithm: String {
    case hmacSha256 = "AWS4-HMAC-SHA256"
}

enum Primitive: Encodable {
    case integer(Int)
    case string(String)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

public extension String {
    public func base64() throws -> String {
        return self.data(using: .utf8)!.base64EncodedString()
    }
}

extension Date {
    public func iso8601(compact: Bool = false) -> (full: String, short: String) {
        let iso8601Formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = compact ? "yyyyMMdd'T'HHmmssXXXXX" : "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            return formatter
        }()
        let dateString = iso8601Formatter.string(from: self)
        let index = dateString.index(dateString.startIndex, offsetBy: compact ? 8 : 10)
        let shortDate = String(dateString[..<index])
        return (full: dateString, short: shortDate)
    }
}

extension ClosedRange: Encodable where Bound: Encodable {
    enum CodingKeys: String, CodingKey {
        case upperBound
        case lowerBound
    }
    
    public func encode(to encoder: Encoder) throws {
        try [
            CodingKeys.lowerBound.stringValue: lowerBound,
            CodingKeys.upperBound.stringValue: upperBound
            ].encode(to: encoder)
    }
}
