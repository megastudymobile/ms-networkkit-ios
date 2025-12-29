import Foundation

/// Todo Repository 구현체
///
/// Domain Layer의 TodoRepositoryProtocol을 구현합니다.
/// Data Source를 사용하여 실제 데이터 작업을 수행하고,
/// DTO를 Domain Entity로 변환합니다.
final class TodoRepository: TodoRepositoryProtocol {
    private let remoteDataSource: TodoRemoteDataSource
    
    init(remoteDataSource: TodoRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchTodos() async throws -> [Todo] {
        let dtos = try await remoteDataSource.fetchTodos()
        return dtos.map { $0.toDomain() }
    }
    
    func fetchTodo(id: Int) async throws -> Todo {
        let dto = try await remoteDataSource.fetchTodo(id: id)
        return dto.toDomain()
    }
    
    func fetchTodos(userId: Int) async throws -> [Todo] {
        let dtos = try await remoteDataSource.fetchTodos(userId: userId)
        return dtos.map { $0.toDomain() }
    }
    
    func createTodo(_ data: TodoCreationData) async throws -> Todo {
        let dto = data.toDTO()
        let resultDTO = try await remoteDataSource.createTodo(dto)
        return resultDTO.toDomain()
    }
    
    func updateTodo(_ todo: Todo) async throws -> Todo {
        let dto = todo.toDTO()
        let resultDTO = try await remoteDataSource.updateTodo(dto)
        return resultDTO.toDomain()
    }
    
    func deleteTodo(id: Int) async throws {
        try await remoteDataSource.deleteTodo(id: id)
    }
}

