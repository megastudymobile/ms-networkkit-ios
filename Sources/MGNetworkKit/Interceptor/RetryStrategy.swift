import Foundation

/// 재시도 전략을 정의하는 열거형
///
/// 재시도 시 대기 시간을 계산하는 다양한 전략을 제공합니다.
///
/// # Examples
/// ```swift
/// // 1. 고정 대기 시간 (1초)
/// let constantStrategy = RetryStrategy.constant(1.0)
///
/// // 2. 선형 증가 (1초, 2초, 3초, 4초, ...)
/// let linearStrategy = RetryStrategy.linear(base: 1.0)
///
/// // 3. 지수 백오프 (2초, 4초, 8초, 16초, ...)
/// let exponentialStrategy = RetryStrategy.exponentialBackoff(base: 2.0)
///
/// // 4. 커스텀 전략
/// let customStrategy = RetryStrategy.custom { attempt in
///     return min(Double(attempt * 2), 10.0) // 최대 10초
/// }
/// ```
public enum RetryStrategy: Sendable {
    /// 고정 대기 시간
    ///
    /// 모든 재시도에서 동일한 대기 시간을 사용합니다.
    ///
    /// - Parameter delay: 대기 시간 (초)
    ///
    /// # Example
    /// ```swift
    /// // 항상 1초 대기
    /// let strategy = RetryStrategy.constant(1.0)
    /// // attempt 0: 1초
    /// // attempt 1: 1초
    /// // attempt 2: 1초
    /// ```
    case constant(TimeInterval)
    
    /// 선형 증가
    ///
    /// 재시도 횟수에 비례하여 대기 시간이 선형적으로 증가합니다.
    ///
    /// - Parameter base: 기본 대기 시간 (초)
    ///
    /// # Example
    /// ```swift
    /// // 1초씩 증가
    /// let strategy = RetryStrategy.linear(base: 1.0)
    /// // attempt 0: 1초 (1 * 1)
    /// // attempt 1: 2초 (1 * 2)
    /// // attempt 2: 3초 (1 * 3)
    /// ```
    case linear(base: TimeInterval)
    
    /// 지수 백오프 (Exponential Backoff)
    ///
    /// 재시도 횟수에 따라 대기 시간이 지수적으로 증가합니다.
    /// 네트워크 혼잡 시 효과적입니다.
    ///
    /// - Parameter base: 기본 대기 시간 (초)
    ///
    /// # Example
    /// ```swift
    /// // 지수적으로 증가
    /// let strategy = RetryStrategy.exponentialBackoff(base: 2.0)
    /// // attempt 0: 2초 (2^0 * 2)
    /// // attempt 1: 4초 (2^1 * 2)
    /// // attempt 2: 8초 (2^2 * 2)
    /// // attempt 3: 16초 (2^3 * 2)
    /// ```
    case exponentialBackoff(base: TimeInterval)
    
    /// 커스텀 전략
    ///
    /// 사용자 정의 로직으로 대기 시간을 계산합니다.
    ///
    /// - Parameter calculator: 시도 횟수를 받아 대기 시간을 반환하는 클로저
    ///
    /// # Example
    /// ```swift
    /// // 최대 10초까지만 증가
    /// let strategy = RetryStrategy.custom { attempt in
    ///     return min(TimeInterval(attempt * 2), 10.0)
    /// }
    /// ```
    case custom(@Sendable (Int) -> TimeInterval)
    
    /// 시도 횟수에 따른 대기 시간을 계산합니다.
    ///
    /// - Parameter attempt: 현재 시도 횟수 (0부터 시작)
    /// - Returns: 대기 시간 (초)
    public func delay(for attempt: Int) -> TimeInterval {
        switch self {
        case .constant(let delay):
            return delay
            
        case .linear(let base):
            return base * TimeInterval(attempt + 1)
            
        case .exponentialBackoff(let base):
            return base * pow(2.0, Double(attempt))
            
        case .custom(let calculator):
            return calculator(attempt)
        }
    }
}

