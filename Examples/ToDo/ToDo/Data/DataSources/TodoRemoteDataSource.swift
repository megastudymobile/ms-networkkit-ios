import Foundation
import MegaNetworkKit

/// Todo Remote Data Source
final class TodoRemoteDataSource: Sendable {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchTodos() async throws -> [TodoDTO] {
        try await networkService.request(FetchTodosRequest())
    }
    
    func fetchTodo(id: Int) async throws -> TodoDTO {
        try await networkService.request(FetchTodoRequest(id: id))
    }
    
    func fetchTodos(userId: Int) async throws -> [TodoDTO] {
        try await networkService.request(FetchUserTodosRequest(userId: userId))
    }
    
    func createTodo(_ dto: TodoCreationDTO) async throws -> TodoDTO {
        try await networkService.request(CreateTodoRequest(dto: dto))
    }
    
    func updateTodo(_ dto: TodoDTO) async throws -> TodoDTO {
        try await networkService.request(UpdateTodoRequest(dto: dto))
    }
    
    func deleteTodo(id: Int) async throws {
        let _: EmptyResponse = try await networkService.request(DeleteTodoRequest(id: id))
    }
}

// MARK: - API Requests

struct FetchTodosRequest: Requestable {
    typealias Response = [TodoDTO]
    
    var path: String { "/todos" }
    var method: HTTPMethod { .get }
}

struct FetchTodoRequest: Requestable {
    typealias Response = TodoDTO
    
    let id: Int
    
    var path: String { "/todos/\(id)" }
    var method: HTTPMethod { .get }
}

struct FetchUserTodosRequest: Requestable {
    typealias Response = [TodoDTO]
    
    let userId: Int
    
    var path: String { "/todos" }
    var method: HTTPMethod { .get }
    var queryParameters: [String: String]? {
        ["userId": "\(userId)"]
    }
}

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

struct DeleteTodoRequest: Requestable {
    typealias Response = EmptyResponse
    
    let id: Int
    
    var path: String { "/todos/\(id)" }
    var method: HTTPMethod { .delete }
}

struct EmptyResponse: Responsable, Sendable {}

