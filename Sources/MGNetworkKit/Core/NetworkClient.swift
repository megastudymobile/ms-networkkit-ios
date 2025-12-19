import Foundation

/// 네트워크 클라이언트
///
/// 실제 네트워크 요청을 수행하는 내부 구현체입니다.
/// struct로 구현하여 자동으로 Sendable을 준수합니다.
struct NetworkClient: Sendable {
    // MARK: - Properties
    
    private let configuration: NetworkConfiguration
    private let session: URLSessionProtocol
    
    // MARK: - Initialization
    
    init(
        configuration: NetworkConfiguration,
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// API 요청을 수행하고 응답을 반환합니다.
    ///
    /// RequestAdapter, ResponseInterceptor, RetryPolicy를 적용하여 요청을 수행합니다.
    ///
    /// - Parameter request: 수행할 API 요청
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: NetworkError
    func request<T: Requestable>(_ request: T) async throws -> T.Response {
        var attempt = 0
        
        while true {
            do {
                // 1. URLRequest 생성
                var urlRequest = try buildURLRequest(from: request)
                
                // 2. RequestAdapter 적용
                if let adapter = configuration.requestAdapter {
                    urlRequest = try await adapter.adapt(urlRequest)
                }
                
                // 3. 네트워크 요청 수행
                let (data, response) = try await performRequest(urlRequest)
                
                // 4. ResponseInterceptor 실행
                if let interceptor = configuration.responseInterceptor {
                    try await interceptor.intercept(data: data, response: response)
                }
                
                // 5. Response 검증
                try validateResponse(response, data: data)
                
                // 6. JSON 디코딩
                return try decode(data, as: T.Response.self)
                
            } catch let error as NetworkError {
                // 7. Retry 로직
                guard let policy = configuration.retryPolicy,
                      policy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }
                
                let delay = policy.retryDelay(for: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                attempt += 1
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Requestable을 URLRequest로 변환합니다.
    private func buildURLRequest<T: Requestable>(from request: T) throws -> URLRequest {
        // URL 생성
        guard var urlComponents = URLComponents(string: configuration.baseURL + request.path) else {
            throw NetworkError.invalidURL
        }
        
        // 쿼리 파라미터 추가
        if let queryParameters = request.queryParameters {
            urlComponents.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // URLRequest 생성
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = configuration.timeout
        
        // 헤더 추가 (공통 헤더 + 요청별 헤더)
        configuration.commonHeaders.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body 추가
        urlRequest.httpBody = request.body
        
        return urlRequest
    }
    
    /// 네트워크 요청을 수행합니다.
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
    
    /// HTTP Response를 검증합니다.
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 200-299 범위를 벗어나면 에러
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
    
    /// JSON 데이터를 디코딩합니다.
    private func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        configuration.configureDecoder(decoder)
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}

