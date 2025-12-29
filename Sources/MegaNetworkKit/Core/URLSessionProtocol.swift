import Foundation

/// URLSession 추상화 프로토콜
///
/// URLSession을 프로토콜로 추상화하여 테스트 시 Mock 주입을 가능하게 합니다.
/// Sendable을 준수하여 여러 Task에서 안전하게 공유할 수 있습니다.
public protocol URLSessionProtocol: Sendable {
    /// 네트워크 요청을 수행하고 데이터를 반환합니다.
    ///
    /// - Parameter request: URLRequest
    /// - Returns: (Data, URLResponse) 튜플
    /// - Throws: URLSession 에러
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Extension

/// URLSession이 URLSessionProtocol을 준수하도록 확장합니다.
extension URLSession: URLSessionProtocol {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

