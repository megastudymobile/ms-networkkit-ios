import XCTest
@testable import MGNetworkKit

final class NetworkServiceTests: XCTestCase {
    // MARK: - Properties
    
    private var configuration: NetworkConfiguration!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        configuration = NetworkConfiguration(
            baseURL: "https://api.example.com",
            timeout: 30
        )
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func test_request_성공_시_응답_반환() async throws {
        // Given
        let mockResponse = MockResponse(id: "1", name: "Test")
        let mockData = try JSONEncoder().encode(mockResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession(
            data: mockData,
            response: httpResponse
        )
        
        let service = NetworkService(
            configuration: configuration,
            session: mockSession
        )
        
        // When
        let result = try await service.request(MockRequest())
        
        // Then
        XCTAssertEqual(result.id, "1")
        XCTAssertEqual(result.name, "Test")
    }
    
    // MARK: - Error Tests
    
    func test_request_네트워크_에러_발생() async {
        // Given
        let mockSession = MockURLSession(
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )
        
        let service = NetworkService(
            configuration: configuration,
            session: mockSession
        )
        
        // When & Then
        do {
            _ = try await service.request(MockRequest())
            XCTFail("에러가 발생해야 합니다")
        } catch let error as NetworkError {
            if case .networkError = error {
                // Success
            } else {
                XCTFail("NetworkError.networkError가 발생해야 합니다")
            }
        } catch {
            XCTFail("예상치 못한 에러가 발생했습니다")
        }
    }
    
    func test_request_HTTP_에러_발생() async {
        // Given
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession(
            data: Data(),
            response: httpResponse
        )
        
        let service = NetworkService(
            configuration: configuration,
            session: mockSession
        )
        
        // When & Then
        do {
            _ = try await service.request(MockRequest())
            XCTFail("에러가 발생해야 합니다")
        } catch let error as NetworkError {
            if case .httpError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("NetworkError.httpError가 발생해야 합니다")
            }
        } catch {
            XCTFail("예상치 못한 에러가 발생했습니다")
        }
    }
    
    func test_request_디코딩_에러_발생() async {
        // Given
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession(
            data: invalidJSON,
            response: httpResponse
        )
        
        let service = NetworkService(
            configuration: configuration,
            session: mockSession
        )
        
        // When & Then
        do {
            _ = try await service.request(MockRequest())
            XCTFail("에러가 발생해야 합니다")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("NetworkError.decodingError가 발생해야 합니다")
            }
        } catch {
            XCTFail("예상치 못한 에러가 발생했습니다")
        }
    }
    
    // MARK: - Configuration Tests
    
    func test_request_공통_헤더_적용() async throws {
        // Given
        let configWithHeaders = NetworkConfiguration(
            baseURL: "https://api.example.com",
            timeout: 30,
            commonHeaders: ["Authorization": "Bearer token"]
        )
        
        let mockResponse = MockResponse(id: "1", name: "Test")
        let mockData = try JSONEncoder().encode(mockResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession(
            data: mockData,
            response: httpResponse
        )
        
        let service = NetworkService(
            configuration: configWithHeaders,
            session: mockSession
        )
        
        // When
        let result = try await service.request(MockRequest())
        
        // Then
        XCTAssertEqual(result.id, "1")
    }
    
    func test_request_쿼리_파라미터_적용() async throws {
        // Given
        let mockResponse = MockResponse(id: "1", name: "Test")
        let mockData = try JSONEncoder().encode(mockResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test?page=1&limit=20")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession(
            data: mockData,
            response: httpResponse
        )
        
        let service = NetworkService(
            configuration: configuration,
            session: mockSession
        )
        
        let requestWithQuery = MockRequest(
            queryParameters: ["page": "1", "limit": "20"]
        )
        
        // When
        let result = try await service.request(requestWithQuery)
        
        // Then
        XCTAssertEqual(result.id, "1")
    }
}

