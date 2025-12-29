import Foundation

/// 재시도 정책을 정의하는 프로토콜
///
/// RetryPolicy는 네트워크 요청 실패 시 재시도 여부와 전략을 결정합니다.
///
/// # Example
/// ```swift
/// let retryPolicy = DefaultRetryPolicy(
///     maxRetryCount: 3,
///     retryableStatusCodes: [408, 429, 500, 502, 503, 504],
///     strategy: .exponentialBackoff(base: 1.0)
/// )
/// ```
public protocol RetryPolicy: Sendable {
    /// 재시도 여부를 결정합니다.
    ///
    /// - Parameters:
    ///   - error: 발생한 에러
    ///   - attempt: 현재 시도 횟수 (0부터 시작)
    /// - Returns: 재시도 여부
    func shouldRetry(error: NetworkError, attempt: Int) -> Bool
    
    /// 재시도 전 대기 시간을 반환합니다.
    ///
    /// - Parameter attempt: 현재 시도 횟수 (0부터 시작)
    /// - Returns: 대기 시간 (초)
    func retryDelay(for attempt: Int) -> TimeInterval
}

// MARK: - DefaultRetryPolicy

/// 기본 재시도 정책 구현
///
/// 특정 HTTP 상태 코드와 네트워크 에러에 대해 재시도를 수행합니다.
public struct DefaultRetryPolicy: RetryPolicy {
    /// 최대 재시도 횟수
    public let maxRetryCount: Int
    
    /// 재시도 가능한 HTTP 상태 코드
    ///
    /// 기본값: [408, 429, 500, 502, 503, 504]
    /// - 408: Request Timeout
    /// - 429: Too Many Requests
    /// - 500: Internal Server Error
    /// - 502: Bad Gateway
    /// - 503: Service Unavailable
    /// - 504: Gateway Timeout
    public let retryableStatusCodes: Set<Int>
    
    /// 재시도 전략
    public let strategy: RetryStrategy
    
    /// DefaultRetryPolicy를 초기화합니다.
    ///
    /// - Parameters:
    ///   - maxRetryCount: 최대 재시도 횟수 (기본값: 3)
    ///   - retryableStatusCodes: 재시도 가능한 HTTP 상태 코드 (기본값: [408, 429, 500, 502, 503, 504])
    ///   - strategy: 재시도 전략 (기본값: exponentialBackoff)
    public init(
        maxRetryCount: Int = 3,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504],
        strategy: RetryStrategy = .exponentialBackoff(base: 2.0)
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatusCodes = retryableStatusCodes
        self.strategy = strategy
    }
    
    public func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
        // 최대 재시도 횟수를 초과하면 재시도하지 않음
        guard attempt < maxRetryCount else { return false }
        
        switch error {
        case .httpError(let statusCode, _):
            // 재시도 가능한 상태 코드인 경우 재시도
            return retryableStatusCodes.contains(statusCode)
            
        case .networkError:
            // 네트워크 에러는 재시도
            return true
            
        default:
            // 나머지 에러는 재시도하지 않음
            return false
        }
    }
    
    public func retryDelay(for attempt: Int) -> TimeInterval {
        return strategy.delay(for: attempt)
    }
}

