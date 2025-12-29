import Foundation

/// Todo 상세 ViewModel
@MainActor
@Observable
final class TodoDetailViewModel {
    // MARK: - State
    
    private(set) var todo: Todo
    var editedTitle: String
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // MARK: - Use Cases
    
    private let updateTodoUseCase: UpdateTodoUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase
    
    // MARK: - Initialization
    
    init(
        todo: Todo,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase
    ) {
        self.todo = todo
        self.editedTitle = todo.title
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
    }
    
    // MARK: - Actions
    
    func toggleCompletion() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedTodo = try await updateTodoUseCase.toggleCompletion(todo)
            todo = updatedTodo
        } catch {
            errorMessage = "상태 변경에 실패했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateTitle() async -> Bool {
        guard hasChanges else { return true }
        
        isLoading = true
        errorMessage = nil
        
        let updatedTodo = todo.update(title: editedTitle)
        
        do {
            let result = try await updateTodoUseCase.execute(updatedTodo)
            todo = result
            editedTitle = result.title
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteTodo() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await deleteTodoUseCase.execute(id: todo.id)
            isLoading = false
            return true
        } catch {
            errorMessage = "삭제에 실패했습니다: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    var hasChanges: Bool {
        editedTitle != todo.title
    }
    
    func clearError() {
        errorMessage = nil
    }
}

