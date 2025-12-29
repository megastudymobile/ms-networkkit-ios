# TodoApp

**MegaNetworkKit**을 사용한 Clean Architecture + MVVM 예제 앱입니다.

## 🏗️ 아키텍처

### Clean Architecture 레이어

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Views, ViewModels)                    │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│  (Entities, Use Cases, Repository 인터페이스) │
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (DTOs, Repository 구현, Data Sources)   │
└─────────────────────────────────────────┘
```

### 디렉토리 구조

```
Sources/
├── App/
│   ├── TodoApp.swift           # 앱 진입점
│   └── DIContainer.swift       # 의존성 주입 컨테이너
│
├── Domain/                     # 비즈니스 로직 (외부 의존성 없음)
│   ├── Entities/
│   │   └── Todo.swift          # 도메인 엔티티
│   ├── UseCases/
│   │   ├── FetchTodosUseCase.swift
│   │   ├── CreateTodoUseCase.swift
│   │   ├── UpdateTodoUseCase.swift
│   │   └── DeleteTodoUseCase.swift
│   └── Repositories/
│       └── TodoRepositoryProtocol.swift
│
├── Data/                       # 데이터 처리
│   ├── DTOs/
│   │   └── TodoDTO.swift       # API 응답 매핑
│   ├── Repositories/
│   │   └── TodoRepository.swift # Repository 구현
│   └── DataSources/
│       └── TodoRemoteDataSource.swift # API 통신
│
└── Presentation/               # UI
    ├── TodoList/
    │   ├── TodoListViewModel.swift
    │   └── TodoListView.swift
    ├── TodoDetail/
    │   ├── TodoDetailViewModel.swift
    │   └── TodoDetailView.swift
    └── CreateTodo/
        ├── CreateTodoViewModel.swift
        └── CreateTodoView.swift
```

## 🚀 실행 방법

### 1. 빌드

```bash
cd Examples/TodoApp
swift build
```

### 2. 실행

```bash
swift run TodoApp
```

### 3. Xcode에서 실행

```bash
open Package.swift
```

Xcode에서 Scheme을 "TodoApp"으로 선택하고 실행합니다.

## ✨ 주요 기능

### CRUD 작업

- ✅ **Create**: 새로운 Todo 생성
- ✅ **Read**: Todo 목록 조회, 상세 정보 보기
- ✅ **Update**: Todo 제목 수정, 완료 상태 토글
- ✅ **Delete**: Todo 삭제

### 필터링

- 전체 보기
- 진행 중만 보기
- 완료됨만 보기

### UI 기능

- Pull to Refresh (목록 새로고침)
- Swipe to Delete (스와이프로 삭제)
- 에러 핸들링 (Alert)
- 로딩 상태 표시

## 🏛️ Clean Architecture 원칙

### 1. 의존성 역전 원칙 (Dependency Inversion Principle)

```swift
// ✅ Domain Layer가 인터페이스 정의
protocol TodoRepositoryProtocol {
    func fetchTodos() async throws -> [Todo]
}

// ✅ Data Layer가 인터페이스 구현
final class TodoRepository: TodoRepositoryProtocol {
    // 구현...
}

// ✅ Use Case는 프로토콜에만 의존
final class FetchTodosUseCase {
    private let repository: TodoRepositoryProtocol  // 구현체 아님!
}
```

### 2. 단일 책임 원칙 (Single Responsibility Principle)

```swift
// ✅ 각 Use Case는 하나의 책임만 가짐
FetchTodosUseCase    // 조회만
CreateTodoUseCase    // 생성만
UpdateTodoUseCase    // 수정만
DeleteTodoUseCase    // 삭제만
```

### 3. 개방-폐쇄 원칙 (Open-Closed Principle)

```swift
// ✅ 새로운 Data Source 추가 시 기존 코드 수정 불필요
protocol TodoRepositoryProtocol {
    func fetchTodos() async throws -> [Todo]
}

// 기존: Remote Data Source
final class TodoRepository: TodoRepositoryProtocol {
    private let remoteDataSource: TodoRemoteDataSource
}

// 추가 가능: Local Data Source (기존 코드 변경 없이)
final class TodoLocalRepository: TodoRepositoryProtocol {
    private let localDataSource: TodoLocalDataSource
}
```

## 📱 MVVM 패턴

### ViewModel 책임

```swift
@MainActor
@Observable
final class TodoListViewModel {
    // 1. 상태 관리
    private(set) var todos: [Todo] = []
    private(set) var isLoading = false
    
    // 2. Use Case 실행
    func fetchTodos() async {
        todos = try await fetchTodosUseCase.execute()
    }
    
    // 3. View 이벤트 처리
    func toggleTodo(_ todo: Todo) async {
        // ...
    }
}
```

### View 책임

```swift
struct TodoListView: View {
    @State private var viewModel: TodoListViewModel
    
    var body: some View {
        // 1. ViewModel 상태 관찰
        List(viewModel.todos) { todo in
            // 2. 사용자 이벤트를 ViewModel로 전달
            TodoRow(todo: todo) {
                Task {
                    await viewModel.toggleTodo(todo)
                }
            }
        }
        // 3. 생명주기 이벤트 처리
        .task {
            await viewModel.fetchTodos()
        }
    }
}
```

## 🌐 API 사용

### JSONPlaceholder

```
Base URL: https://jsonplaceholder.typicode.com
```

### 엔드포인트

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/todos` | 전체 Todo 목록 |
| GET | `/todos/:id` | 특정 Todo 조회 |
| GET | `/todos?userId=:userId` | 사용자별 Todo 목록 |
| POST | `/todos` | Todo 생성 |
| PUT | `/todos/:id` | Todo 수정 |
| DELETE | `/todos/:id` | Todo 삭제 |

### MegaNetworkKit 사용 예시

```swift
// 1. Request 정의
struct FetchTodosRequest: Requestable {
    typealias Response = [TodoDTO]
    
    var path: String { "/todos" }
    var method: HTTPMethod { .get }
}

// 2. 실행
let todos = try await networkService.request(FetchTodosRequest())
```

## 🧪 테스트 가능한 설계

### Mock Repository

```swift
final class MockTodoRepository: TodoRepositoryProtocol {
    var mockTodos: [Todo] = []
    
    func fetchTodos() async throws -> [Todo] {
        return mockTodos
    }
}

// 테스트에서 사용
let mockRepository = MockTodoRepository()
mockRepository.mockTodos = [/* test data */]

let useCase = FetchTodosUseCase(repository: mockRepository)
let todos = try await useCase.execute()
```

## 📚 학습 포인트

### 1. Async/Await

```swift
// ✅ async/await 사용
func fetchTodos() async throws -> [Todo] {
    let dtos = try await remoteDataSource.fetchTodos()
    return dtos.map { $0.toDomain() }
}
```

### 2. Sendable & Swift 6 Concurrency

```swift
// ✅ 모든 모델이 Sendable 준수
struct Todo: Sendable { }
protocol TodoRepositoryProtocol: Sendable { }
```

### 3. SwiftUI @Observable

```swift
// ✅ Swift 5.9+ @Observable 사용
@MainActor
@Observable
final class TodoListViewModel {
    var todos: [Todo] = []  // 자동으로 관찰됨
}
```

### 4. Dependency Injection

```swift
// ✅ DIContainer로 중앙 집중식 관리
@MainActor
final class DIContainer {
    static let shared = DIContainer()
    
    func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(
            fetchTodosUseCase: makeFetchTodosUseCase(),
            updateTodoUseCase: makeUpdateTodoUseCase(),
            deleteTodoUseCase: makeDeleteTodoUseCase()
        )
    }
}
```

## 🎯 확장 가능성

이 아키텍처는 다음과 같은 확장이 쉽습니다:

- ✅ Local Database 추가 (Core Data, Realm)
- ✅ 오프라인 모드
- ✅ 캐싱 레이어
- ✅ 인증/권한 관리
- ✅ 다른 API로 전환
- ✅ 단위 테스트 추가

## 📄 라이선스

MIT License

## 👤 작성자

MegaStudy Mobile Development Team

