import SwiftUI

/// Todo 생성 화면
///
/// 새로운 Todo를 추가하는 폼을 제공합니다.
struct CreateTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateTodoViewModel
    
    init(viewModel: CreateTodoViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("할 일 정보") {
                    TextField("할 일 제목", text: $viewModel.title, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Stepper("사용자 ID: \(viewModel.userId)", value: $viewModel.userId, in: 1...10)
                }
                
                Section {
                    Button {
                        Task {
                            let success = await viewModel.createTodo()
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("추가")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                }
            }
            .navigationTitle("새 할 일")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
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
}

