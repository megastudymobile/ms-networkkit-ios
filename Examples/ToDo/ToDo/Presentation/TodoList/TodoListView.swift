import SwiftUI

/// Todo 목록 화면
struct TodoListView: View {
    @State private var viewModel: TodoListViewModel
    @State private var showingCreateTodo = false
    @State private var selectedTodo: Todo?
    
    private let onTodoCreated: () async -> Void
    
    init(
        viewModel: TodoListViewModel,
        onTodoCreated: @escaping () async -> Void
    ) {
        self.viewModel = viewModel
        self.onTodoCreated = onTodoCreated
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.todos.isEmpty {
                    ProgressView("불러오는 중...")
                } else if viewModel.todos.isEmpty {
                    emptyView
                } else {
                    todoList
                }
            }
            .navigationTitle("할 일 목록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateTodo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("필터", selection: $viewModel.filterOption) {
                            ForEach(TodoListViewModel.FilterOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                await viewModel.fetchTodos()
            }
            .refreshable {
                await viewModel.fetchTodos()
            }
            .sheet(isPresented: $showingCreateTodo) {
                CreateTodoView(
                    viewModel: DIContainer.shared.makeCreateTodoViewModel()
                )
                .presentationDetents([.medium, .large])
                .onDisappear {
                    Task {
                        await onTodoCreated()
                    }
                }
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(
                    viewModel: DIContainer.shared.makeTodoDetailViewModel(todo: todo)
                )
                .onDisappear {
                    Task {
                        await viewModel.fetchTodos()
                    }
                }
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var todoList: some View {
        List {
            ForEach(viewModel.todos) { todo in
                TodoRow(todo: todo) {
                    Task {
                        await viewModel.toggleTodo(todo)
                    }
                } onTap: {
                    selectedTodo = todo
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteTodo(todo)
                        }
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "할 일이 없습니다",
            systemImage: "checkmark.circle",
            description: Text("새로운 할 일을 추가해보세요")
        )
    }
}

// MARK: - Todo Row

struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 체크박스 버튼
            Button(action: onToggle) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.completed ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Todo 내용 (탭하면 상세 화면)
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.body)
                        .foregroundStyle(todo.completed ? .secondary : .primary)
                        .strikethrough(todo.completed)
                        .multilineTextAlignment(.leading)
                    
                    Text("사용자 #\(todo.userId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }
}

