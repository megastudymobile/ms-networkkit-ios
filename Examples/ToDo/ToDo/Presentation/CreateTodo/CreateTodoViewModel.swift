import Foundation

/// Todo 생성 ViewModel
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
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func clearError() {
        errorMessage = nil
    }
}

