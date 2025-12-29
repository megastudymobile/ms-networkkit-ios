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

// MARK: - Array Conformance

/// Array가 Responsable 요소를 가질 때 자동으로 Responsable 준수
extension Array: Responsable where Element: Responsable {}

