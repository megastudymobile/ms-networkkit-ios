import Foundation
import MegaNetworkKit

/// Todo Remote Data Source
///
/// JSONPlaceholder API와 통신하는 데이터 소스입니다.
/// MegaNetworkKit을 사용하여 네트워크 요청을 수행합니다.
final class TodoRemoteDataSource: Sendable {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 전체 Todo 목록 조회
    func fetchTodos() async throws -> [TodoDTO] {
        try await networkService.request(FetchTodosRequest())
    }
    
    /// 특정 Todo 조회
    func fetchTodo(id: Int) async throws -> TodoDTO {
        try await networkService.request(FetchTodoRequest(id: id))
    }
    
    /// 사용자별 Todo 목록 조회
    func fetchTodos(userId: Int) async throws -> [TodoDTO] {
        try await networkService.request(FetchUserTodosRequest(userId: userId))
    }
    
    /// Todo 생성
    func createTodo(_ dto: TodoCreationDTO) async throws -> TodoDTO {
        try await networkService.request(CreateTodoRequest(dto: dto))
    }
    
    /// Todo 수정
    func updateTodo(_ dto: TodoDTO) async throws -> TodoDTO {
        try await networkService.request(UpdateTodoRequest(dto: dto))
    }
    
    /// Todo 삭제
    func deleteTodo(id: Int) async throws {
        let _: EmptyResponse = try await networkService.request(DeleteTodoRequest(id: id))
    }
}

// MARK: - API Requests

/// 전체 Todo 목록 조회 요청
struct FetchTodosRequest: Requestable {
    typealias Response = [TodoDTO]
    
    var path: String { "/todos" }
    var method: HTTPMethod { .get }
}

/// 특정 Todo 조회 요청
struct FetchTodoRequest: Requestable {
    typealias Response = TodoDTO
    
    let id: Int
    
    var path: String { "/todos/\(id)" }
    var method: HTTPMethod { .get }
}

/// 사용자별 Todo 목록 조회 요청
struct FetchUserTodosRequest: Requestable {
    typealias Response = [TodoDTO]
    
    let userId: Int
    
    var path: String { "/todos" }
    var method: HTTPMethod { .get }
    var queryParameters: [String: String]? {
        ["userId": "\(userId)"]
    }
}

/// Todo 생성 요청
struct CreateTodoRequest: Requestable {
    typealias Response = TodoDTO
    
    let dto: TodoCreationDTO
    
    var path: String { "/todos" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        [HTTPHeader.contentType: ContentType.json]
    }
    var body: Data? {
        try? JSONEncoder().encode(dto)
    }
}

/// Todo 수정 요청
struct UpdateTodoRequest: Requestable {
    typealias Response = TodoDTO
    
    let dto: TodoDTO
    
    var path: String { "/todos/\(dto.id)" }
    var method: HTTPMethod { .put }
    var headers: [String: String]? {
        [HTTPHeader.contentType: ContentType.json]
    }
    var body: Data? {
        try? JSONEncoder().encode(dto)
    }
}

/// Todo 삭제 요청
struct DeleteTodoRequest: Requestable {
    typealias Response = EmptyResponse
    
    let id: Int
    
    var path: String { "/todos/\(id)" }
    var method: HTTPMethod { .delete }
}

/// 빈 응답 (삭제 성공)
struct EmptyResponse: Responsable, Sendable {}

