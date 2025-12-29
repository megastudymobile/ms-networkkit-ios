import Foundation

/// Todo 목록 조회 Use Case
final class FetchTodosUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Todo] {
        try await repository.fetchTodos()
    }
    
    func execute(userId: Int) async throws -> [Todo] {
        try await repository.fetchTodos(userId: userId)
    }
    
    func execute(completed: Bool? = nil) async throws -> [Todo] {
        let todos = try await repository.fetchTodos()
        
        guard let completed = completed else {
            return todos
        }
        
        return todos.filter { $0.completed == completed }
    }
}

