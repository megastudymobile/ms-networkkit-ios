import Foundation

// MARK: - TargetType Support

extension NetworkService {
    /// TargetType을 사용한 네트워크 요청
    ///
    /// Enum 기반 API 정의를 사용하여 더 간결하고 타입 안전한 요청을 수행합니다.
    ///
    /// # Example
    /// ```swift
    /// enum UserAPI {
    ///     case fetchUsers
    ///     case fetchUser(id: Int)
    /// }
    ///
    /// extension UserAPI: TargetType {
    ///     typealias Response = [UserDTO]
    ///     var path: String { "/users" }
    ///     var method: HTTPMethod { .get }
    /// }
    ///
    /// // 사용
    /// let users = try await networkService.request(UserAPI.fetchUsers)
    /// let user = try await networkService.request(UserAPI.fetchUser(id: 1))
    /// ```
    ///
    /// - Parameter target: TargetType을 준수하는 Enum case
    /// - Returns: Target의 Response 타입 인스턴스
    /// - Throws: NetworkError
    public func request<Target: TargetType>(
        _ target: Target
    ) async throws -> Target.Response {
        // TargetType을 Requestable로 변환
        let adapter = TargetTypeAdapter(target: target)
        return try await self.request(adapter)
    }
}

// MARK: - Internal Adapter

/// TargetType을 Requestable로 변환하는 내부 어댑터
///
/// 기존 NetworkService의 Requestable 기반 구현을 재사용하기 위한 브릿지 역할을 합니다.
/// 사용자는 이 타입을 직접 사용할 필요가 없습니다.
private struct TargetTypeAdapter<Target: TargetType>: Requestable {
    typealias Response = Target.Response
    
    let target: Target
    
    var path: String {
        target.path
    }
    
    var method: HTTPMethod {
        target.method
    }
    
    var headers: [String: String]? {
        target.headers
    }
    
    var queryParameters: [String: String]? {
        target.queryParameters
    }
    
    var body: Data? {
        target.body
    }
}

