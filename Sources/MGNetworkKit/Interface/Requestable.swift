import Foundation

/// API 요청을 정의하는 프로토콜
///
/// 각 프로젝트는 이 프로토콜을 채택하여 자신의 API를 정의합니다.
/// Sendable을 준수하여 Swift 6의 Strict Concurrency를 지원합니다.
///
/// # Example
/// ```swift
/// struct GetUserRequest: Requestable {
///     typealias Response = UserResponse
///
///     let userId: String
///
///     var path: String { "/users/\(userId)" }
///     var method: HTTPMethod { .get }
///     var headers: [String: String]? { ["Authorization": "Bearer token"] }
///     var queryParameters: [String: String]? { nil }
///     var body: Data? { nil }
/// }
/// ```
public protocol Requestable: Sendable {
    /// 이 요청에 대한 응답 타입
    associatedtype Response: Responsable
    
    /// API 엔드포인트 경로 (베이스 URL을 제외한 경로)
    /// 예: "/users/123"
    var path: String { get }
    
    /// HTTP 메서드
    var method: HTTPMethod { get }
    
    /// HTTP 헤더
    /// 이 헤더는 NetworkConfiguration의 공통 헤더와 병합됩니다.
    var headers: [String: String]? { get }
    
    /// 쿼리 파라미터
    /// 예: ["page": "1", "limit": "20"]
    var queryParameters: [String: String]? { get }
    
    /// HTTP Body 데이터
    /// POST, PUT, PATCH 요청 시 사용됩니다.
    var body: Data? { get }
}

// MARK: - Default Implementations

public extension Requestable {
    /// 기본값: 헤더 없음
    var headers: [String: String]? { nil }
    
    /// 기본값: 쿼리 파라미터 없음
    var queryParameters: [String: String]? { nil }
    
    /// 기본값: Body 없음
    var body: Data? { nil }
}

