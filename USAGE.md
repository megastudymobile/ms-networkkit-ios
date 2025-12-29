# MegaNetworkKit 사용 가이드

## 📦 다른 프로젝트에서 사용하는 방법

### 방법 1: 로컬 패키지로 추가 (개발 중)

#### Xcode에서 추가
1. File → Add Package Dependencies...
2. "Add Local..." 버튼 클릭
3. `MegaNetworkKit` 폴더 선택
4. "Add Package" 클릭

#### Package.swift에 추가
```swift
dependencies: [
    .package(path: "../MegaNetworkKit")
]
```

---

### 방법 2: Git 저장소로 추가 (배포용)

#### 1. Git 저장소 초기화
```bash
cd /Users/kimdongjoo/Desktop/MegaNetworkKit
git init
git add .
git commit -m "Initial commit: MegaNetworkKit v1.0.0"
git tag 1.0.0
```

#### 2. GitHub/GitLab에 푸시
```bash
git remote add origin https://github.com/your-org/MegaNetworkKit.git
git push -u origin main
git push --tags
```

#### 3. 다른 프로젝트에서 사용
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/your-org/MegaNetworkKit.git", from: "1.0.0")
]
```

또는 Xcode에서:
- File → Add Package Dependencies...
- URL 입력: `https://github.com/your-org/MegaNetworkKit.git`

---

### 방법 3: Xcode 프로젝트에 직접 추가

1. MegaNetworkKit 폴더를 프로젝트 폴더 옆에 배치
```
YourProject/
├── YourProject.xcodeproj
└── ...

MegaNetworkKit/
├── Package.swift
└── Sources/
```

2. Xcode에서:
   - File → Add Package Dependencies...
   - Add Local... → MegaNetworkKit 선택

---

## 🚀 빠른 시작

### 1. Import
```swift
import MegaNetworkKit
```

### 2. Configuration 설정
```swift
let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    timeout: 30,
    commonHeaders: ["Content-Type": "application/json"]
)

let service = NetworkService(configuration: config)
```

### 3. API 요청 정의
```swift
struct GetUserRequest: Requestable {
    typealias Response = User
    
    let userId: String
    
    var path: String { "/users/\(userId)" }
    var method: HTTPMethod { .get }
}

struct User: Responsable {
    let id: String
    let name: String
    let email: String
}
```

### 4. 요청 실행
```swift
Task {
    do {
        let user = try await service.request(GetUserRequest(userId: "123"))
        print(user.name)
    } catch {
        print("Error: \(error)")
    }
}
```

---

## 🎯 TargetType (Enum 기반 API - 권장)

Moya 스타일의 Enum 기반 API 정의로 더 간결하고 타입 안전한 코드를 작성할 수 있습니다.

### 기본 사용법

```swift
import MegaNetworkKit

// 1. Enum으로 API 정의
enum UserAPI {
    case fetchUsers
    case fetchUser(id: Int)
    case createUser(name: String, email: String)
    case updateUser(id: Int, name: String)
    case deleteUser(id: Int)
}

// 2. TargetType 구현
extension UserAPI: TargetType {
    typealias Response = UserDTO
    
    var path: String {
        switch self {
        case .fetchUsers:
            return "/users"
        case .fetchUser(let id), .updateUser(let id, _), .deleteUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUsers, .fetchUser:
            return .get
        case .createUser:
            return .post
        case .updateUser:
            return .put
        case .deleteUser:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createUser, .updateUser:
            return [HTTPHeader.contentType: ContentType.json]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .createUser(let name, let email):
            return try? JSONEncoder().encode(["name": name, "email": email])
        case .updateUser(_, let name):
            return try? JSONEncoder().encode(["name": name])
        default:
            return nil
        }
    }
}

// 3. Response Model
struct UserDTO: Responsable {
    let id: Int
    let name: String
    let email: String
}

// 4. 사용 - 훨씬 간결!
let users = try await service.request(UserAPI.fetchUsers)
let user = try await service.request(UserAPI.fetchUser(id: 1))
let created = try await service.request(UserAPI.createUser(
    name: "John", 
    email: "john@example.com"
))
```

### 실전 예제: Todo API

```swift
enum TodoAPI {
    case fetchTodos
    case fetchTodo(id: Int)
    case createTodo(TodoCreationDTO)
    case updateTodo(TodoDTO)
    case deleteTodo(id: Int)
}

extension TodoAPI: TargetType {
    typealias Response = TodoDTO
    
    var path: String {
        switch self {
        case .fetchTodos:
            return "/todos"
        case .fetchTodo(let id), .updateTodo(let todo), .deleteTodo(let id):
            return "/todos/\(id ?? todo.id)"
        case .createTodo:
            return "/todos"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchTodos, .fetchTodo: return .get
        case .createTodo: return .post
        case .updateTodo: return .put
        case .deleteTodo: return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createTodo, .updateTodo:
            return [HTTPHeader.contentType: ContentType.json]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .createTodo(let dto):
            return try? JSONEncoder().encode(dto)
        case .updateTodo(let dto):
            return try? JSONEncoder().encode(dto)
        default:
            return nil
        }
    }
}

// Repository에서 사용
final class TodoRepository {
    private let networkService: NetworkService
    
    func fetchTodos() async throws -> [TodoDTO] {
        try await networkService.request(TodoAPI.fetchTodos)
    }
    
    func createTodo(_ dto: TodoCreationDTO) async throws -> TodoDTO {
        try await networkService.request(TodoAPI.createTodo(dto))
    }
}
```

### TargetType vs Requestable 비교

**Requestable (기존)**:
```swift
// ❌ 6개 API = 6개 struct (약 150줄)
struct FetchTodosRequest: Requestable { ... }
struct FetchTodoRequest: Requestable { ... }
struct CreateTodoRequest: Requestable { ... }
struct UpdateTodoRequest: Requestable { ... }
struct DeleteTodoRequest: Requestable { ... }
struct FetchUserTodosRequest: Requestable { ... }

// 사용
let todos = try await service.request(FetchTodosRequest())
let todo = try await service.request(FetchTodoRequest(id: 1))
```

**TargetType (권장)**:
```swift
// ✅ 6개 API = 1개 enum (약 70줄, 53% 감소)
enum TodoAPI: TargetType {
    case fetchTodos
    case fetchTodo(id: Int)
    case createTodo(TodoCreationDTO)
    case updateTodo(TodoDTO)
    case deleteTodo(id: Int)
    case fetchUserTodos(userId: Int)
    // ...
}

// 사용 - 더 간결하고 명확
let todos = try await service.request(TodoAPI.fetchTodos)
let todo = try await service.request(TodoAPI.fetchTodo(id: 1))
```

### 언제 TargetType을 사용해야 할까?

✅ **TargetType 권장**:
- 관련 API가 여러 개 (3개 이상)
- 도메인 별로 API 그룹화가 필요한 경우
- 새 프로젝트 시작

✅ **Requestable 권장**:
- 단일 API만 필요한 경우
- 기존 Requestable 코드와 호환 필요

💡 **두 방식 모두 사용 가능**: 같은 프로젝트에서 혼용 가능합니다!

더 자세한 내용은 [API 설계 개선 문서](./Documents/API-Design-Improvement.md)를 참조하세요.

---

## 🔧 고급 사용법

### Interceptor 사용

#### 인증 토큰 자동 추가
```swift
final class AuthAdapter: RequestAdapter {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adapted = request
        let token = await TokenManager.shared.getToken()
        adapted.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return adapted
    }
}

let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    requestAdapter: AuthAdapter()
)
```

#### 로깅 추가
```swift
final class LoggingInterceptor: ResponseInterceptor {
    func intercept(data: Data, response: URLResponse) async throws {
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 [\(httpResponse.statusCode)] \(httpResponse.url?.path ?? "")")
            if let json = try? JSONSerialization.jsonObject(with: data) {
                print("📦 Response: \(json)")
            }
        }
    }
}

let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    responseInterceptor: LoggingInterceptor()
)
```

#### 자동 재시도
```swift
let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    retryPolicy: DefaultRetryPolicy(
        maxRetryCount: 3,
        retryableStatusCodes: [408, 500, 502, 503],
        strategy: .exponentialBackoff(base: 2.0)
    )
)
```

---

## 📝 예제 프로젝트

### JSONPlaceholder API 사용 예시

```swift
import MegaNetworkKit
import SwiftUI

// 1. Configuration
let config = NetworkConfiguration(
    baseURL: "https://jsonplaceholder.typicode.com",
    timeout: 30,
    commonHeaders: ["Content-Type": "application/json"],
    configureDecoder: { decoder in
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    },
    responseInterceptor: LoggingInterceptor(),
    retryPolicy: DefaultRetryPolicy(maxRetryCount: 3)
)

// 2. API Requests
struct GetPostsRequest: Requestable {
    typealias Response = [Post]
    
    var path: String { "/posts" }
    var method: HTTPMethod { .get }
}

struct CreatePostRequest: Requestable {
    typealias Response = Post
    
    let title: String
    let body: String
    let userId: Int
    
    var path: String { "/posts" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        [HTTPHeader.contentType: ContentType.json]
    }
    var body: Data? {
        try? JSONEncoder().encode([
            "title": title,
            "body": body,
            "userId": userId
        ])
    }
}

// 3. Response Models
struct Post: Responsable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// 4. ViewModel
@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = NetworkService(configuration: config)
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await service.request(GetPostsRequest())
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPost(title: String, body: String) async {
        do {
            let newPost = try await service.request(
                CreatePostRequest(title: title, body: body, userId: 1)
            )
            posts.insert(newPost, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// 5. View
struct PostListView: View {
    @StateObject private var viewModel = PostViewModel()
    
    var body: some View {
        List(viewModel.posts, id: \.id) { post in
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.body)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .task {
            await viewModel.fetchPosts()
        }
    }
}
```

---

## 🧪 테스트

### 단위 테스트
```bash
cd MegaNetworkKit
swift test
```

### Xcode에서 테스트
```bash
xcodebuild test -scheme MegaNetworkKit -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 📚 추가 문서

- [README.md](README.md) - 기본 사용법
- [Package.swift](Package.swift) - 패키지 설정

---

## 🆘 문제 해결

### 빌드 에러: "Cannot find 'MegaNetworkKit' in scope"
→ File → Add Package Dependencies에서 MegaNetworkKit 추가 확인

### 빌드 에러: "Module 'MegaNetworkKit' not found"
→ Target → Build Phases → Link Binary With Libraries에 MegaNetworkKit 추가

### Swift 버전 에러
→ Xcode 16.0+ 및 Swift 6.0+ 필요

---

## 📞 지원

이슈가 있으면 GitHub Issues에 등록해주세요.

