import Foundation
import MegaNetworkKit

// MARK: - Todo Query API (조회)

/// Todo 조회 API
enum TodoQueryAPI {
    case fetchTodos
    case fetchTodo(id: Int)
    case fetchUserTodos(userId: Int)
}

extension TodoQueryAPI: TargetType {
    typealias Response = [TodoDTO]
    
    var path: String {
        switch self {
        case .fetchTodos, .fetchUserTodos:
            return "/todos"
        case .fetchTodo(let id):
            return "/todos/\(id)"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .fetchUserTodos(let userId):
            return ["userId": "\(userId)"]
        default:
            return nil
        }
    }
}

// MARK: - Todo Mutation API (생성/수정/삭제)

/// Todo 변경 API
enum TodoMutationAPI {
    case create(TodoCreationDTO)
    case update(TodoDTO)
    case delete(id: Int)
}

extension TodoMutationAPI: TargetType {
    typealias Response = TodoDTO
    
    var path: String {
        switch self {
        case .create:
            return "/todos"
        case .update(let dto):
            return "/todos/\(dto.id)"
        case .delete(let id):
            return "/todos/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .create, .update:
            return [HTTPHeader.contentType: ContentType.json]
        case .delete:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .create(let dto):
            return try? JSONEncoder().encode(dto)
        case .update(let dto):
            return try? JSONEncoder().encode(dto)
        case .delete:
            return nil
        }
    }
}
