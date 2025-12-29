import Foundation
@testable import MegaNetworkKit

// MARK: - Mock Request

struct MockRequest: Requestable {
    typealias Response = MockResponse
    
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryParameters: [String: String]?  // Sendable을 위해 Any -> String으로 변경
    let body: Data?
    
    init(
        path: String = "/test",
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
    }
}

// MARK: - Mock Response

struct MockResponse: Responsable, Encodable {
    let id: String
    let name: String
}

