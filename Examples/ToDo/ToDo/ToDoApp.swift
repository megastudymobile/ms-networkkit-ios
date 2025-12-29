//
//  TodoApp.swift
//  Todo
//
//  Created by Kim Dongjoo on 12/29/25.
//

import SwiftUI

/// TodoApp 진입점
///
/// Clean Architecture + MVVM 패턴으로 구현된 예제 앱입니다.
/// MegaNetworkKit을 사용하여 JSONPlaceholder API와 통신합니다.
@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Root View
struct RootView: View {
    @State private var viewModel: TodoListViewModel
    
    init() {
        let container = DIContainer.shared
        self.viewModel = container.makeTodoListViewModel()
    }
    
    var body: some View {
        TodoListView(viewModel: viewModel) {
            await viewModel.fetchTodos()
        }
    }
}
