import Foundation

/// Todo 삭제 Use Case
final class DeleteTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws {
        try await repository.deleteTodo(id: id)
    }
}

