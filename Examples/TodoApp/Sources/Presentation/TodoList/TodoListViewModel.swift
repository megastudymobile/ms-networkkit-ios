import Foundation

/// Todo 목록 ViewModel
///
/// MVVM 패턴의 ViewModel입니다.
/// View의 상태를 관리하고 Use Case를 통해 비즈니스 로직을 실행합니다.
@MainActor
@Observable
final class TodoListViewModel {
    // MARK: - State
    
    private(set) var todos: [Todo] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var filterOption: FilterOption = .all {
        didSet {
            applyFilter()
        }
    }
    
    private var allTodos: [Todo] = []
    
    // MARK: - Use Cases
    
    private let fetchTodosUseCase: FetchTodosUseCase
    private let updateTodoUseCase: UpdateTodoUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase
    
    // MARK: - Initialization
    
    init(
        fetchTodosUseCase: FetchTodosUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase
    ) {
        self.fetchTodosUseCase = fetchTodosUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
    }
    
    // MARK: - Actions
    
    /// Todo 목록 불러오기
    func fetchTodos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            allTodos = try await fetchTodosUseCase.execute()
            applyFilter()
        } catch {
            errorMessage = "할 일 목록을 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Todo 완료 상태 토글
    func toggleTodo(_ todo: Todo) async {
        do {
            let updatedTodo = try await updateTodoUseCase.toggleCompletion(todo)
            updateLocalTodo(updatedTodo)
        } catch {
            errorMessage = "할 일 업데이트에 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// Todo 삭제
    func deleteTodo(_ todo: Todo) async {
        do {
            try await deleteTodoUseCase.execute(id: todo.id)
            removeLocalTodo(todo)
        } catch {
            errorMessage = "할 일 삭제에 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func applyFilter() {
        switch filterOption {
        case .all:
            todos = allTodos
        case .active:
            todos = allTodos.filter { !$0.completed }
        case .completed:
            todos = allTodos.filter { $0.completed }
        }
    }
    
    private func updateLocalTodo(_ updatedTodo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
            allTodos[index] = updatedTodo
            applyFilter()
        }
    }
    
    private func removeLocalTodo(_ todo: Todo) {
        allTodos.removeAll { $0.id == todo.id }
        applyFilter()
    }
}

// MARK: - Filter Option

extension TodoListViewModel {
    enum FilterOption: String, CaseIterable {
        case all = "전체"
        case active = "진행 중"
        case completed = "완료됨"
    }
}

