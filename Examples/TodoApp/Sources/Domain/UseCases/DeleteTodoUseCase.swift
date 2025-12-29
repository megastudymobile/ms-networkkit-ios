import Foundation

/// Todo 삭제 Use Case
///
/// Todo를 삭제하는 비즈니스 로직을 담당합니다.
final class DeleteTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Todo 삭제 실행
    func execute(id: Int) async throws {
        try await repository.deleteTodo(id: id)
    }
    
    /// 여러 Todo 삭제
    func execute(ids: [Int]) async throws {
        // 병렬로 삭제 실행
        try await withThrowingTaskGroup(of: Void.self) { group in
            for id in ids {
                group.addTask {
                    try await self.repository.deleteTodo(id: id)
                }
            }
            
            try await group.waitForAll()
        }
    }
}

