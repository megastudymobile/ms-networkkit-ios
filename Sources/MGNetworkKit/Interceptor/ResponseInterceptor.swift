import Foundation

/// 응답 후에 처리 로직을 실행하는 프로토콜
///
/// ResponseInterceptor는 네트워크 응답을 받은 후 추가 처리를 수행할 수 있습니다.
/// 로깅, 분석, 에러 핸들링 등의 용도로 사용됩니다.
///
/// # Example
/// ```swift
/// final class LoggingInterceptor: ResponseInterceptor {
///     func intercept(data: Data, response: URLResponse) async throws {
///         if let httpResponse = response as? HTTPURLResponse {
///             print("✅ Response: \(httpResponse.statusCode)")
///         }
///     }
/// }
/// ```
public protocol ResponseInterceptor: Sendable {
    /// Response를 가로채어 처리합니다.
    ///
    /// - Parameters:
    ///   - data: Response data
    ///   - response: URLResponse
    /// - Throws: 처리 중 발생한 에러
    func intercept(data: Data, response: URLResponse) async throws
}

