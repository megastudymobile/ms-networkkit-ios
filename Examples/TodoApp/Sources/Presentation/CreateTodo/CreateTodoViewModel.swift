import Foundation

/// Todo 생성 ViewModel
///
/// 새로운 Todo를 생성하는 화면의 상태를 관리합니다.
@MainActor
@Observable
final class CreateTodoViewModel {
    // MARK: - State
    
    var title = ""
    var userId = 1
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // MARK: - Use Case
    
    private let createTodoUseCase: CreateTodoUseCase
    
    // MARK: - Initialization
    
    init(createTodoUseCase: CreateTodoUseCase) {
        self.createTodoUseCase = createTodoUseCase
    }
    
    // MARK: - Actions
    
    /// Todo 생성
    func createTodo() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let data = Todo.create(
            userId: userId,
            title: title,
            completed: false
        )
        
        do {
            _ = try await createTodoUseCase.execute(data)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// 입력값 검증
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
}

