import Foundation

/// Todo 상세 ViewModel
///
/// Todo의 상세 정보를 보여주고 수정/삭제를 처리합니다.
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
    
    /// Todo 완료 상태 토글
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
    
    /// Todo 제목 수정
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
    
    /// Todo 삭제
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
    
    /// 변경사항 확인
    var hasChanges: Bool {
        editedTitle != todo.title
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
}

