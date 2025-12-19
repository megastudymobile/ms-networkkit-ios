import Foundation

/// 네트워크 서비스의 인터페이스
///
/// 비즈니스 레이어에서 네트워크 요청을 수행하기 위한 프로토콜입니다.
/// Sendable을 준수하여 여러 Task에서 안전하게 공유할 수 있습니다.
///
/// # Example
/// ```swift
/// let service: NetworkServiceProtocol = NetworkService(configuration: config)
/// let response = try await service.request(GetUserRequest(userId: "123"))
/// ```
public protocol NetworkServiceProtocol: Sendable {
    /// API 요청을 수행하고 응답을 반환합니다.
    ///
    /// - Parameter request: 수행할 API 요청
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: NetworkError
    func request<T: Requestable>(_ request: T) async throws -> T.Response
}

