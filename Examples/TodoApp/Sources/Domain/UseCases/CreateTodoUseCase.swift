import Foundation

/// Todo 생성 Use Case
///
/// 새로운 Todo를 생성하는 비즈니스 로직을 담당합니다.
final class CreateTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Todo 생성 실행
    func execute(_ data: TodoCreationData) async throws -> Todo {
        // 비즈니스 규칙 검증
        guard !data.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard data.title.count <= 200 else {
            throw TodoValidationError.titleTooLong
        }
        
        return try await repository.createTodo(data)
    }
}

/// Todo 검증 에러
enum TodoValidationError: LocalizedError {
    case emptyTitle
    case titleTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "할 일 제목을 입력해주세요."
        case .titleTooLong:
            return "할 일 제목은 200자를 초과할 수 없습니다."
        }
    }
}

