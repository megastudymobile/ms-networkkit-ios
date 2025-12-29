import Foundation
@testable import MegaNetworkKit

/// Mock URLSession
///
/// 테스트를 위한 URLSession Mock 구현입니다.
/// Sendable을 준수하여 Swift 6 Concurrency를 지원합니다.
final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    // MARK: - Properties
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    // MARK: - Initialization
    
    init(
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) {
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
    }
    
    // MARK: - URLSessionProtocol
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.unknown)
        }
        
        return (data, response)
    }
}

