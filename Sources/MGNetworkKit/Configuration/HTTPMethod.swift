import Foundation

/// HTTP 메서드
///
/// RESTful API에서 사용되는 표준 HTTP 메서드를 정의합니다.
/// enum이므로 자동으로 Sendable을 준수합니다.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}

