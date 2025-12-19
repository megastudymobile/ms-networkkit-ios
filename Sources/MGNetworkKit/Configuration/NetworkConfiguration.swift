import Foundation

/// 네트워크 설정
///
/// API 베이스 URL, 타임아웃, 공통 헤더, Interceptor 등을 설정합니다.
/// struct이므로 자동으로 Sendable을 준수합니다.
///
/// # Example
/// ```swift
/// let config = NetworkConfiguration(
///     baseURL: "https://api.example.com",
///     timeout: 30,
///     commonHeaders: [
///         "API-Key": "your-api-key",
///         "Accept-Language": "ko-KR"
///     ],
///     requestAdapter: AuthTokenAdapter(),
///     retryPolicy: DefaultRetryPolicy(maxRetryCount: 3)
/// )
/// ```
public struct NetworkConfiguration: Sendable {
    /// API 베이스 URL
    public let baseURL: String
    
    /// 요청 타임아웃 (초 단위)
    public let timeout: TimeInterval
    
    /// 모든 요청에 공통으로 추가될 HTTP 헤더
    public let commonHeaders: [String: String]
    
    /// JSONDecoder 설정을 위한 클로저
    /// 날짜 디코딩 전략 등을 커스터마이징할 수 있습니다.
    public let configureDecoder: @Sendable (JSONDecoder) -> Void
    
    /// 요청 전에 URLRequest를 수정하는 어댑터
    public let requestAdapter: (any RequestAdapter)?
    
    /// 응답 후에 처리 로직을 실행하는 인터셉터
    public let responseInterceptor: (any ResponseInterceptor)?
    
    /// 재시도 정책
    public let retryPolicy: (any RetryPolicy)?
    
    /// 초기화
    ///
    /// - Parameters:
    ///   - baseURL: API 베이스 URL (예: "https://api.example.com")
    ///   - timeout: 요청 타임아웃 (기본값: 30초)
    ///   - commonHeaders: 공통 HTTP 헤더 (기본값: 빈 딕셔너리)
    ///   - configureDecoder: JSONDecoder 설정 클로저 (기본값: 없음)
    ///   - requestAdapter: 요청 어댑터 (기본값: nil)
    ///   - responseInterceptor: 응답 인터셉터 (기본값: nil)
    ///   - retryPolicy: 재시도 정책 (기본값: nil)
    public init(
        baseURL: String,
        timeout: TimeInterval = 30,
        commonHeaders: [String: String] = [:],
        configureDecoder: @Sendable @escaping (JSONDecoder) -> Void = { _ in },
        requestAdapter: (any RequestAdapter)? = nil,
        responseInterceptor: (any ResponseInterceptor)? = nil,
        retryPolicy: (any RetryPolicy)? = nil
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.commonHeaders = commonHeaders
        self.configureDecoder = configureDecoder
        self.requestAdapter = requestAdapter
        self.responseInterceptor = responseInterceptor
        self.retryPolicy = retryPolicy
    }
}

