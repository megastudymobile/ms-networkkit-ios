import Foundation

/// Todo 수정 Use Case
final class UpdateTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ todo: Todo) async throws -> Todo {
        guard !todo.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard todo.title.count <= 200 else {
            throw TodoValidationError.titleTooLong
        }
        
        return try await repository.updateTodo(todo)
    }
    
    func toggleCompletion(_ todo: Todo) async throws -> Todo {
        let updatedTodo = todo.update(completed: !todo.completed)
        return try await repository.updateTodo(updatedTodo)
    }
}

