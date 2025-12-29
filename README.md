# MegaNetworkKit

Swift 6 기반의 현대적이고 타입 안전한 iOS 네트워크 라이브러리입니다.

> MegaStudy Mobile Development Team

## 특징

- ✅ **Swift 6.0** + Strict Concurrency 완벽 지원
- ✅ **Async/Await** 기반 모던 API
- ✅ **Type-Safe** 프로토콜 지향 설계
- ✅ **Sendable** 준수로 Thread-Safe 보장
- ✅ **순수 Swift** (외부 의존성 없음)
- ✅ **Interceptor** 지원 (RequestAdapter, ResponseInterceptor, RetryPolicy)
- ✅ **TargetType** 지원 (Moya 스타일 Enum 기반 API 정의)
- ✅ **iOS 15.0+** 지원

## 요구사항

- iOS 15.0+
- Swift 6.0+
- Xcode 16.0+

## 설치

### Swift Package Manager

#### Xcode에서 추가

1. File → Add Package Dependencies...
2. 패키지 URL 입력 또는 Add Local... 선택
3. NetworkKit 선택

#### Package.swift에 추가

```swift
dependencies: [
    .package(url: "https://gitlab.megastudy.net/mobiledev/MegaNetworkKit.git", from: "1.0.0")
]
```

또는 로컬 패키지:

```swift
dependencies: [
    .package(path: "../MegaNetworkKit")
]
```

그리고 타겟에 추가:

```swift
.target(
    name: "YourTarget",
    dependencies: ["MegaNetworkKit"]
)
```

## 사용 방법

### 1. NetworkConfiguration 설정

```swift
import MegaNetworkKit

let configuration = NetworkConfiguration(
    baseURL: "https://api.example.com",
    timeout: 30,
    commonHeaders: [
        "Content-Type": "application/json",
        "API-Key": "your-api-key"
    ],
    configureDecoder: { decoder in
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
)
```

### 2. API Request 정의

```swift
struct GetUserRequest: Requestable {
    typealias Response = UserResponse
    
    let userId: String
    
    var path: String { "/users/\(userId)" }
    var method: HTTPMethod { .get }
    var headers: [String: String]? { 
        ["Authorization": "Bearer token"] 
    }
}
```

### 3. Response Model 정의

```swift
struct UserResponse: Responsable {
    let id: String
    let name: String
    let email: String
}
```

### 4. NetworkService 사용

```swift
let service = NetworkService(configuration: configuration)

Task {
    do {
        let user = try await service.request(
            GetUserRequest(userId: "123")
        )
        print(user.name)
    } catch {
        print("Error: \(error)")
    }
}
```

## TargetType (Enum 기반 API 정의)

Moya 스타일의 Enum 기반 API 정의를 지원합니다. 관련 API를 하나의 Enum으로 그룹화하여 더 간결하고 타입 안전한 코드를 작성할 수 있습니다.

### 1. TargetType 정의

```swift
import MegaNetworkKit

enum UserAPI {
    case fetchUsers
    case fetchUser(id: Int)
    case createUser(name: String, email: String)
    case updateUser(id: Int, name: String)
    case deleteUser(id: Int)
}

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
            let dto = ["name": name, "email": email]
            return try? JSONEncoder().encode(dto)
        case .updateUser(_, let name):
            let dto = ["name": name]
            return try? JSONEncoder().encode(dto)
        default:
            return nil
        }
    }
}
```

### 2. Response Model

```swift
struct UserDTO: Responsable {
    let id: Int
    let name: String
    let email: String
}

// Array도 자동으로 Responsable 지원
extension UserAPI {
    typealias Response = [UserDTO]  // 목록 조회용
}
```

### 3. 사용 예시

```swift
let service = NetworkService(configuration: configuration)

// 간결하고 명확한 API 호출
let users = try await service.request(UserAPI.fetchUsers)
let user = try await service.request(UserAPI.fetchUser(id: 1))
let created = try await service.request(UserAPI.createUser(
    name: "John Doe", 
    email: "john@example.com"
))
```

### 4. TargetType vs Requestable 비교

**Requestable (기존 방식)**:
```swift
// ❌ 각 API마다 struct 필요
struct FetchUsersRequest: Requestable {
    typealias Response = [UserDTO]
    var path: String { "/users" }
    var method: HTTPMethod { .get }
}

struct FetchUserRequest: Requestable {
    typealias Response = UserDTO
    let id: Int
    var path: String { "/users/\(id)" }
    var method: HTTPMethod { .get }
}

// 사용
let users = try await service.request(FetchUsersRequest())
let user = try await service.request(FetchUserRequest(id: 1))
```

**TargetType (권장 방식)**:
```swift
// ✅ 하나의 Enum으로 관리
enum UserAPI: TargetType {
    case fetchUsers
    case fetchUser(id: Int)
    
    typealias Response = UserDTO
    
    var path: String {
        switch self {
        case .fetchUsers: return "/users"
        case .fetchUser(let id): return "/users/\(id)"
        }
    }
    
    var method: HTTPMethod { .get }
}

// 사용 (더 간결하고 명확)
let users = try await service.request(UserAPI.fetchUsers)
let user = try await service.request(UserAPI.fetchUser(id: 1))
```

### 5. TargetType 장점

- ✅ **코드 절감**: 53% 이상 코드 감소 (관련 API 그룹화)
- ✅ **가독성**: 의미 중심의 간결한 API 호출
- ✅ **타입 안전성**: Enum case로 컴파일 타임 검증
- ✅ **확장성**: 새 API 추가 시 case만 추가
- ✅ **그룹화**: 도메인별 API를 한 곳에서 관리
- ✅ **호환성**: 기존 Requestable과 함께 사용 가능

더 자세한 비교는 [API 설계 개선 문서](./Documents/API-Design-Improvement.md)를 참조하세요.

## Interceptor 사용

### RequestAdapter (요청 전 수정)

```swift
final class AuthTokenAdapter: RequestAdapter {
    private let tokenProvider: () async -> String?
    
    init(tokenProvider: @escaping () async -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        
        if let token = await tokenProvider() {
            adaptedRequest.setValue(
                "Bearer \(token)", 
                forHTTPHeaderField: "Authorization"
            )
        }
        
        return adaptedRequest
    }
}
```

### ResponseInterceptor (응답 후 처리)

```swift
final class LoggingInterceptor: ResponseInterceptor {
    func intercept(data: Data, response: URLResponse) async throws {
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ [\(httpResponse.statusCode)] \(httpResponse.url?.path ?? "")")
        }
    }
}
```

### RetryPolicy (재시도 정책)

```swift
let retryPolicy = DefaultRetryPolicy(
    maxRetryCount: 3,
    retryableStatusCodes: [408, 429, 500, 502, 503, 504],
    strategy: .exponentialBackoff(base: 2.0)
)
```

### Configuration에 Interceptor 추가

```swift
let configuration = NetworkConfiguration(
    baseURL: "https://api.example.com",
    timeout: 30,
    commonHeaders: ["Content-Type": "application/json"],
    configureDecoder: { $0.keyDecodingStrategy = .convertFromSnakeCase },
    requestAdapter: AuthTokenAdapter(tokenProvider: { await getToken() }),
    responseInterceptor: LoggingInterceptor(),
    retryPolicy: DefaultRetryPolicy(
        maxRetryCount: 3,
        strategy: .exponentialBackoff(base: 2.0)
    )
)
```

## POST 요청 예시

```swift
struct CreateProductRequest: Requestable {
    typealias Response = ProductResponse
    
    let product: Product
    
    var path: String { "/products" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { 
        [HTTPHeader.contentType: ContentType.json] 
    }
    var body: Data? {
        try? JSONEncoder().encode(product)
    }
}

struct ProductResponse: Responsable {
    let id: String
    let name: String
    let price: Int
}
```

## Retry Strategy

NetworkKit은 4가지 재시도 전략을 제공합니다:

### 1. Constant (고정 대기)
```swift
.constant(1.0)  // 항상 1초 대기
```

### 2. Linear (선형 증가)
```swift
.linear(base: 1.0)  // 1초, 2초, 3초, 4초...
```

### 3. Exponential Backoff (지수 증가)
```swift
.exponentialBackoff(base: 2.0)  // 2초, 4초, 8초, 16초...
```

### 4. Custom (커스텀)
```swift
.custom { attempt in
    return min(Double(attempt * 2), 10.0)  // 최대 10초
}
```

## Swift 6 Concurrency

NetworkKit은 Swift 6의 Strict Concurrency를 완벽하게 지원합니다.

```swift
// 여러 Task에서 안전하게 공유 가능
let service = NetworkService(configuration: configuration)

Task {
    let user = try await service.request(GetUserRequest(userId: "1"))
}

Task {
    let product = try await service.request(GetProductRequest(id: "100"))
}
```

모든 public 타입이 `Sendable`을 준수하여:
- Data race 컴파일 타임 검증
- Thread-safe한 설계
- Actor와 함께 안전하게 사용 가능

## 에러 처리

```swift
do {
    let response = try await service.request(request)
} catch let error as NetworkError {
    switch error {
    case .invalidURL:
        print("유효하지 않은 URL")
    case .httpError(let statusCode, let data):
        print("HTTP 에러: \(statusCode)")
    case .decodingError(let message):
        print("디코딩 실패: \(message)")
    case .networkError(let message):
        print("네트워크 에러: \(message)")
    case .invalidResponse:
        print("유효하지 않은 응답")
    }
}
```

## 아키텍처

NetworkKit은 다음과 같은 계층 구조를 가집니다:

```
┌─────────────────────────────────────┐
│      NetworkService (Public)        │  ← 외부 인터페이스
├─────────────────────────────────────┤
│       NetworkClient (Internal)      │  ← 실제 구현
├─────────────────────────────────────┤
│  Interceptor Layer                  │
│  - RequestAdapter                   │
│  - ResponseInterceptor              │
│  - RetryPolicy                      │
├─────────────────────────────────────┤
│       URLSession                    │  ← 시스템 레이어
└─────────────────────────────────────┘
```

### 주요 컴포넌트

- **NetworkService**: 외부에 노출되는 메인 인터페이스
- **NetworkClient**: 실제 네트워크 요청 수행
- **Requestable**: API 요청 정의 프로토콜
- **Responsable**: API 응답 모델 프로토콜
- **NetworkConfiguration**: 네트워크 설정 (BaseURL, 헤더, Interceptor 등)
- **NetworkError**: 타입 안전한 에러 처리

## 테스트

```bash
swift test
```

또는 Xcode에서:
```bash
xcodebuild test -scheme NetworkKit -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 라이선스

MIT License

## 기여

이슈와 PR은 언제나 환영합니다!

## 작성자

MegaStudy Mobile Development Team

