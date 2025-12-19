import Foundation

/// 네트워크 서비스
///
/// 외부에서 사용하는 메인 인터페이스입니다.
/// NetworkServiceProtocol을 구현하며, 내부적으로 NetworkClient를 사용합니다.
///
/// final class지만 모든 프로퍼티가 immutable이고 Sendable 타입이므로
/// @unchecked Sendable을 사용하여 Thread-safety를 보장합니다.
///
/// # Example
/// ```swift
/// let config = NetworkConfiguration(baseURL: "https://api.example.com")
/// let service = NetworkService(configuration: config)
///
/// let user = try await service.request(GetUserRequest(userId: "123"))
/// ```
public final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {
    // MARK: - Properties
    
    private let client: NetworkClient
    
    // MARK: - Initialization
    
    /// NetworkService를 초기화합니다.
    ///
    /// - Parameters:
    ///   - configuration: 네트워크 설정
    ///   - session: URLSession (기본값: URLSession.shared, 테스트 시 Mock 주입 가능)
    public init(
        configuration: NetworkConfiguration,
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.client = NetworkClient(
            configuration: configuration,
            session: session
        )
    }
    
    // MARK: - NetworkServiceProtocol
    
    /// API 요청을 수행하고 응답을 반환합니다.
    ///
    /// - Parameter request: 수행할 API 요청
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: NetworkError
    ///
    /// # Example
    /// ```swift
    /// let response = try await service.request(GetUserRequest(userId: "123"))
    /// print(response.name)
    /// ```
    public func request<T: Requestable>(_ request: T) async throws -> T.Response {
        try await client.request(request)
    }
}

