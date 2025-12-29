import Foundation

/// API 응답 DTO를 정의하는 프로토콜
///
/// 각 프로젝트는 이 프로토콜을 채택하여 자신의 Response 모델을 정의합니다.
/// Decodable과 Sendable을 준수해야 합니다.
///
/// # Example
/// ```swift
/// struct UserResponse: Responsable {
///     let id: String
///     let name: String
///     let email: String
/// }
/// ```
public protocol Responsable: Decodable, Sendable {}

