import Foundation

/// 요청 전에 URLRequest를 수정하는 프로토콜
///
/// RequestAdapter는 네트워크 요청이 실행되기 전에 URLRequest를 가로채어 수정할 수 있습니다.
/// 헤더 추가, 인증 토큰 삽입, 로깅 등의 용도로 사용됩니다.
///
/// async를 지원하므로 비동기적으로 토큰을 가져오는 등의 작업이 가능합니다.
///
/// # Example
/// ```swift
/// final class AuthTokenAdapter: RequestAdapter {
///     private let tokenProvider: () async -> String?
///
///     init(tokenProvider: @escaping () async -> String?) {
///         self.tokenProvider = tokenProvider
///     }
///
///     func adapt(_ request: URLRequest) async throws -> URLRequest {
///         var adaptedRequest = request
///
///         if let token = await tokenProvider() {
///             adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
///         }
///
///         return adaptedRequest
///     }
/// }
/// ```
public protocol RequestAdapter: Sendable {
    /// URLRequest를 수정합니다.
    ///
    /// - Parameter request: 원본 URLRequest
    /// - Returns: 수정된 URLRequest
    /// - Throws: NetworkError.adapterError
    func adapt(_ request: URLRequest) async throws -> URLRequest
}

