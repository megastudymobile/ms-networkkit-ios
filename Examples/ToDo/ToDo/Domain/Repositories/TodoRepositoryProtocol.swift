import Foundation

/// Todo Repository 프로토콜
///
/// Domain Layer에서 정의하는 인터페이스입니다.
/// Data Layer에서 이 프로토콜을 구현하여 의존성 역전 원칙(DIP)을 따릅니다.
protocol TodoRepositoryProtocol: Sendable {
    /// 전체 Todo 목록 조회
    func fetchTodos() async throws -> [Todo]
    
    /// 특정 Todo 조회
    func fetchTodo(id: Int) async throws -> Todo
    
    /// 사용자별 Todo 목록 조회
    func fetchTodos(userId: Int) async throws -> [Todo]
    
    /// Todo 생성
    func createTodo(_ data: TodoCreationData) async throws -> Todo
    
    /// Todo 수정
    func updateTodo(_ todo: Todo) async throws -> Todo
    
    /// Todo 삭제
    func deleteTodo(id: Int) async throws
}

