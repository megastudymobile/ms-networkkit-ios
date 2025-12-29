import Foundation

/// Todo 목록 조회 Use Case
///
/// 단일 책임 원칙(SRP)에 따라 Todo 목록 조회만을 담당합니다.
/// Repository에 의존하지만 구현체가 아닌 프로토콜에 의존합니다(DIP).
final class FetchTodosUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    /// 전체 Todo 목록 조회
    func execute() async throws -> [Todo] {
        try await repository.fetchTodos()
    }
    
    /// 사용자별 Todo 목록 조회
    func execute(userId: Int) async throws -> [Todo] {
        try await repository.fetchTodos(userId: userId)
    }
    
    /// 완료 여부로 필터링된 Todo 목록
    func execute(completed: Bool? = nil) async throws -> [Todo] {
        let todos = try await repository.fetchTodos()
        
        guard let completed = completed else {
            return todos
        }
        
        return todos.filter { $0.completed == completed }
    }
}

