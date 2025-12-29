import Foundation

/// Moya 스타일의 API 정의 프로토콜
///
/// 관련 API를 Enum으로 그룹화하여 관리할 수 있습니다.
/// 각 case는 다른 파라미터를 가질 수 있으며, extension에서 구현을 정의합니다.
///
/// # Example
/// ```swift
/// enum UserAPI {
///     case fetchUsers
///     case fetchUser(id: Int)
///     case createUser(name: String, email: String)
///     case updateUser(id: Int, name: String)
///     case deleteUser(id: Int)
/// }
///
/// extension UserAPI: TargetType {
///     typealias Response = UserDTO
///
///     var path: String {
///         switch self {
///         case .fetchUsers:
///             return "/users"
///         case .fetchUser(let id), .updateUser(let id, _), .deleteUser(let id):
///             return "/users/\(id)"
///         case .createUser:
///             return "/users"
///         }
///     }
///
///     var method: HTTPMethod {
///         switch self {
///         case .fetchUsers, .fetchUser:
///             return .get
///         case .createUser:
///             return .post
///         case .updateUser:
///             return .put
///         case .deleteUser:
///             return .delete
///         }
///     }
///
///     var body: Data? {
///         switch self {
///         case .createUser(let name, let email):
///             return try? JSONEncoder().encode(["name": name, "email": email])
///         case .updateUser(_, let name):
///             return try? JSONEncoder().encode(["name": name])
///         default:
///             return nil
///         }
///     }
/// }
///
/// // 사용
/// let users = try await networkService.request(UserAPI.fetchUsers)
/// let user = try await networkService.request(UserAPI.fetchUser(id: 1))
/// ```
public protocol TargetType: Sendable {
    /// 응답 타입
    ///
    /// API 호출 결과로 받을 모델 타입을 지정합니다.
    /// Responsable 프로토콜을 준수해야 합니다.
    associatedtype Response: Responsable
    
    /// API 엔드포인트 경로
    ///
    /// Base URL을 제외한 경로를 반환합니다.
    ///
    /// # Example
    /// ```swift
    /// var path: String {
    ///     switch self {
    ///     case .fetchUsers: return "/users"
    ///     case .fetchUser(let id): return "/users/\(id)"
    ///     }
    /// }
    /// ```
    var path: String { get }
    
    /// HTTP 메서드
    ///
    /// GET, POST, PUT, DELETE 등을 반환합니다.
    ///
    /// # Example
    /// ```swift
    /// var method: HTTPMethod {
    ///     switch self {
    ///     case .fetchUsers: return .get
    ///     case .createUser: return .post
    ///     }
    /// }
    /// ```
    var method: HTTPMethod { get }
    
    /// 커스텀 헤더 (옵션)
    ///
    /// 기본값: nil
    /// Base configuration의 commonHeaders와 병합됩니다.
    ///
    /// # Example
    /// ```swift
    /// var headers: [String: String]? {
    ///     switch self {
    ///     case .createUser:
    ///         return [HTTPHeader.contentType: ContentType.json]
    ///     default:
    ///         return nil
    ///     }
    /// }
    /// ```
    var headers: [String: String]? { get }
    
    /// 쿼리 파라미터 (옵션)
    ///
    /// 기본값: nil
    /// URL의 ?key=value 형태로 추가됩니다.
    ///
    /// # Example
    /// ```swift
    /// var queryParameters: [String: String]? {
    ///     switch self {
    ///     case .fetchUsers(let page, let limit):
    ///         return ["page": "\(page)", "limit": "\(limit)"]
    ///     default:
    ///         return nil
    ///     }
    /// }
    /// ```
    var queryParameters: [String: String]? { get }
    
    /// 요청 바디 (옵션)
    ///
    /// 기본값: nil
    /// POST, PUT 등에서 전송할 데이터를 반환합니다.
    ///
    /// # Example
    /// ```swift
    /// var body: Data? {
    ///     switch self {
    ///     case .createUser(let dto):
    ///         return try? JSONEncoder().encode(dto)
    ///     default:
    ///         return nil
    ///     }
    /// }
    /// ```
    var body: Data? { get }
}

// MARK: - Default Implementation

public extension TargetType {
    /// 기본 헤더는 nil (commonHeaders만 사용)
    var headers: [String: String]? { nil }
    
    /// 기본 쿼리 파라미터는 nil
    var queryParameters: [String: String]? { nil }
    
    /// 기본 바디는 nil
    var body: Data? { nil }
}

