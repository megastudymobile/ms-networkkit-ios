import Foundation

/// Todo 수정 Use Case
///
/// 기존 Todo를 수정하는 비즈니스 로직을 담당합니다.
final class UpdateTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Todo 수정 실행
    func execute(_ todo: Todo) async throws -> Todo {
        // 비즈니스 규칙 검증
        guard !todo.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard todo.title.count <= 200 else {
            throw TodoValidationError.titleTooLong
        }
        
        return try await repository.updateTodo(todo)
    }
    
    /// Todo 완료 상태 토글
    func toggleCompletion(_ todo: Todo) async throws -> Todo {
        let updatedTodo = todo.update(completed: !todo.completed)
        return try await repository.updateTodo(updatedTodo)
    }
}

