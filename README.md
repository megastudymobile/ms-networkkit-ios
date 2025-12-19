# MGNetworkKit

Swift 6 기반의 현대적이고 타입 안전한 iOS 네트워크 라이브러리입니다.

> MegaStudy Mobile Development Team

## 특징

- ✅ **Swift 6.0** + Strict Concurrency 완벽 지원
- ✅ **Async/Await** 기반 모던 API
- ✅ **Type-Safe** 프로토콜 지향 설계
- ✅ **Sendable** 준수로 Thread-Safe 보장
- ✅ **순수 Swift** (외부 의존성 없음)
- ✅ **Interceptor** 지원 (RequestAdapter, ResponseInterceptor, RetryPolicy)
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
    .package(url: "https://gitlab.megastudy.net/mobiledev/MGNetworkKit.git", from: "1.0.0")
]
```

또는 로컬 패키지:

```swift
dependencies: [
    .package(path: "../MGNetworkKit")
]
```

그리고 타겟에 추가:

```swift
.target(
    name: "YourTarget",
    dependencies: ["MGNetworkKit"]
)
```

## 사용 방법

### 1. NetworkConfiguration 설정

```swift
import MGNetworkKit

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

