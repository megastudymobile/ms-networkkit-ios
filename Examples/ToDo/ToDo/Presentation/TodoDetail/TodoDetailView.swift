import SwiftUI

/// Todo 상세 화면
struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TodoDetailViewModel
    @State private var showingDeleteConfirmation = false
    
    init(viewModel: TodoDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    LabeledContent("ID") {
                        Text("#\(viewModel.todo.id)")
                    }
                    
                    LabeledContent("사용자 ID") {
                        Text("#\(viewModel.todo.userId)")
                    }
                    
                    LabeledContent("상태") {
                        HStack {
                            Image(systemName: viewModel.todo.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.todo.completed ? .green : .gray)
                            Text(viewModel.todo.completed ? "완료됨" : "진행 중")
                        }
                    }
                }
                
                Section("할 일 제목") {
                    TextField("제목", text: $viewModel.editedTitle, axis: .vertical)
                        .lineLimit(3...10)
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.toggleCompletion()
                        }
                    } label: {
                        Label(
                            viewModel.todo.completed ? "진행 중으로 변경" : "완료로 변경",
                            systemImage: viewModel.todo.completed ? "arrow.uturn.backward.circle" : "checkmark.circle"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("삭제", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("할 일 상세")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            let success = await viewModel.updateTitle()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.hasChanges || viewModel.isLoading)
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
            .confirmationDialog("정말 삭제하시겠습니까?", isPresented: $showingDeleteConfirmation) {
                Button("삭제", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteTodo()
                        if success {
                            dismiss()
                        }
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 작업은 되돌릴 수 없습니다.")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
}

