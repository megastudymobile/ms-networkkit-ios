import Foundation
import Testing
@testable import MegaNetworkKit

// MARK: - Mock API

enum MockAPI: TargetType {
    case fetchItems
    case fetchItem(id: Int)
    case createItem(name: String)
    case updateItem(id: Int, name: String)
    case deleteItem(id: Int)
    case fetchWithQuery(page: Int, limit: Int)
    
    typealias Response = MockItemResponse
    
    var path: String {
        switch self {
        case .fetchItems:
            return "/items"
        case .fetchItem(let id):
            return "/items/\(id)"
        case .createItem:
            return "/items"
        case .updateItem(let id, _):
            return "/items/\(id)"
        case .deleteItem(let id):
            return "/items/\(id)"
        case .fetchWithQuery:
            return "/items"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchItems, .fetchItem, .fetchWithQuery:
            return .get
        case .createItem:
            return .post
        case .updateItem:
            return .put
        case .deleteItem:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createItem, .updateItem:
            return [HTTPHeader.contentType: ContentType.json]
        default:
            return nil
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .fetchWithQuery(let page, let limit):
            return ["page": "\(page)", "limit": "\(limit)"]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .createItem(let name):
            return try? JSONEncoder().encode(["name": name])
        case .updateItem(_, let name):
            return try? JSONEncoder().encode(["name": name])
        default:
            return nil
        }
    }
}

struct MockItemResponse: Responsable {
    let id: Int
    let name: String
}

// MARK: - Tests

@Suite("TargetType Tests")
struct TargetTypeTests {
    @Test("fetchItems has correct path and method")
    func testFetchItemsPath() {
        let api = MockAPI.fetchItems
        
        #expect(api.path == "/items")
        #expect(api.method == .get)
        #expect(api.headers == nil)
        #expect(api.queryParameters == nil)
        #expect(api.body == nil)
    }
    
    @Test("fetchItem with id has correct path")
    func testFetchItemWithId() {
        let api = MockAPI.fetchItem(id: 123)
        
        #expect(api.path == "/items/123")
        #expect(api.method == .get)
    }
    
    @Test("createItem has correct method and headers")
    func testCreateItem() {
        let api = MockAPI.createItem(name: "Test Item")
        
        #expect(api.path == "/items")
        #expect(api.method == .post)
        #expect(api.headers?[HTTPHeader.contentType] == ContentType.json)
        #expect(api.body != nil)
    }
    
    @Test("updateItem has correct path and method")
    func testUpdateItem() {
        let api = MockAPI.updateItem(id: 456, name: "Updated")
        
        #expect(api.path == "/items/456")
        #expect(api.method == .put)
        #expect(api.headers?[HTTPHeader.contentType] == ContentType.json)
        #expect(api.body != nil)
    }
    
    @Test("deleteItem has correct method")
    func testDeleteItem() {
        let api = MockAPI.deleteItem(id: 789)
        
        #expect(api.path == "/items/789")
        #expect(api.method == .delete)
        #expect(api.headers == nil)
        #expect(api.body == nil)
    }
    
    @Test("fetchWithQuery has correct query parameters")
    func testFetchWithQuery() {
        let api = MockAPI.fetchWithQuery(page: 2, limit: 20)
        
        #expect(api.path == "/items")
        #expect(api.method == .get)
        #expect(api.queryParameters?["page"] == "2")
        #expect(api.queryParameters?["limit"] == "20")
    }
}

@Suite("NetworkService+TargetType Integration Tests")
struct NetworkServiceTargetTypeTests {
    @Test("TargetType request can be made")
    func testTargetTypeRequest() async throws {
        // Given
        let configuration = NetworkConfiguration(
            baseURL: "https://jsonplaceholder.typicode.com",
            timeout: 30
        )
        let service = NetworkService(configuration: configuration)
        
        // TargetType 정의
        enum TestAPI: TargetType {
            case fetchTodo(id: Int)
            
            typealias Response = TestTodoDTO
            
            var path: String {
                switch self {
                case .fetchTodo(let id):
                    return "/todos/\(id)"
                }
            }
            
            var method: HTTPMethod { .get }
        }
        
        struct TestTodoDTO: Responsable {
            let id: Int
            let userId: Int
            let title: String
            let completed: Bool
        }
        
        // When
        let todo = try await service.request(TestAPI.fetchTodo(id: 1))
        
        // Then
        #expect(todo.id == 1)
        #expect(todo.title.isEmpty == false)
    }
}

