import Foundation
import MegaNetworkKit

/// Dependency Injection Container
@MainActor
final class DIContainer {
    static let shared = DIContainer()
    
    // MARK: - Core Dependencies
    
    private let networkService: NetworkService
    private let todoRepository: TodoRepositoryProtocol
    
    // MARK: - Initialization
    
    private init() {
        // Network Configuration
        let configuration = NetworkConfiguration(
            baseURL: "https://jsonplaceholder.typicode.com",
            timeout: 30,
            commonHeaders: [
                "Content-Type": "application/json"
            ],
            configureDecoder: { decoder in
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
        )
        
        // Network Service
        self.networkService = NetworkService(configuration: configuration)
        
        // Data Sources
        let remoteDataSource = TodoRemoteDataSource(networkService: networkService)
        
        // Repository
        self.todoRepository = TodoRepository(remoteDataSource: remoteDataSource)
    }
    
    // MARK: - Use Cases
    
    func makeFetchTodosUseCase() -> FetchTodosUseCase {
        FetchTodosUseCase(repository: todoRepository)
    }
    
    func makeCreateTodoUseCase() -> CreateTodoUseCase {
        CreateTodoUseCase(repository: todoRepository)
    }
    
    func makeUpdateTodoUseCase() -> UpdateTodoUseCase {
        UpdateTodoUseCase(repository: todoRepository)
    }
    
    func makeDeleteTodoUseCase() -> DeleteTodoUseCase {
        DeleteTodoUseCase(repository: todoRepository)
    }
    
    // MARK: - ViewModels
    
    func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(
            fetchTodosUseCase: makeFetchTodosUseCase(),
            updateTodoUseCase: makeUpdateTodoUseCase(),
            deleteTodoUseCase: makeDeleteTodoUseCase()
        )
    }
    
    func makeCreateTodoViewModel() -> CreateTodoViewModel {
        CreateTodoViewModel(
            createTodoUseCase: makeCreateTodoUseCase()
        )
    }
    
    func makeTodoDetailViewModel(todo: Todo) -> TodoDetailViewModel {
        TodoDetailViewModel(
            todo: todo,
            updateTodoUseCase: makeUpdateTodoUseCase(),
            deleteTodoUseCase: makeDeleteTodoUseCase()
        )
    }
}

