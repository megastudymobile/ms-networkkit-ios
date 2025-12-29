import Foundation

/// 네트워크 에러
///
/// NetworkKit에서 발생할 수 있는 모든 에러를 정의합니다.
/// Sendable을 준수하여 Swift 6의 Strict Concurrency를 지원합니다.
public enum NetworkError: Error, Sendable {
    /// URL 생성 실패
    /// baseURL + path 조합이 유효하지 않을 때 발생합니다.
    case invalidURL
    
    /// 유효하지 않은 응답
    /// URLResponse가 HTTPURLResponse로 캐스팅되지 않을 때 발생합니다.
    case invalidResponse
    
    /// HTTP 에러
    /// HTTP 상태 코드가 200-299 범위를 벗어날 때 발생합니다.
    /// - statusCode: HTTP 상태 코드
    /// - data: 응답 데이터 (에러 메시지 파싱에 사용 가능)
    case httpError(statusCode: Int, data: Data?)
    
    /// JSON 디코딩 에러
    /// 응답 데이터를 Response 타입으로 디코딩하는 데 실패했을 때 발생합니다.
    /// - message: 에러 메시지
    case decodingError(String)
    
    /// 네트워크 에러
    /// URLSession에서 발생한 에러 (타임아웃, 연결 실패 등)
    /// - message: 에러 메시지
    case networkError(String)
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
            
        case .invalidResponse:
            return "서버로부터 유효하지 않은 응답을 받았습니다."
            
        case .httpError(let statusCode, _):
            return "HTTP 에러가 발생했습니다. (상태 코드: \(statusCode))"
            
        case .decodingError(let message):
            return "응답 데이터 디코딩에 실패했습니다: \(message)"
            
        case .networkError(let message):
            return "네트워크 에러가 발생했습니다: \(message)"
        }
    }
}

