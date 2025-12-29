import Foundation

/// Todo 생성 Use Case
final class CreateTodoUseCase: Sendable {
    private let repository: TodoRepositoryProtocol
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ data: TodoCreationData) async throws -> Todo {
        guard !data.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard data.title.count <= 200 else {
            throw TodoValidationError.titleTooLong
        }
        
        return try await repository.createTodo(data)
    }
}

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

