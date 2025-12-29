import Foundation

/// Todo 도메인 엔티티
///
/// Clean Architecture의 Domain Layer에 위치한 비즈니스 모델입니다.
/// 외부 의존성이 없는 순수한 도메인 객체입니다.
struct Todo: Identifiable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
    
    init(
        id: Int,
        userId: Int,
        title: String,
        completed: Bool
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.completed = completed
    }
}

// MARK: - Factory Methods

extension Todo {
    /// 새로운 Todo 생성용 (ID 없음)
    static func create(
        userId: Int,
        title: String,
        completed: Bool = false
    ) -> TodoCreationData {
        TodoCreationData(
            userId: userId,
            title: title,
            completed: completed
        )
    }
    
    /// Todo 수정
    func update(
        title: String? = nil,
        completed: Bool? = nil
    ) -> Todo {
        Todo(
            id: self.id,
            userId: self.userId,
            title: title ?? self.title,
            completed: completed ?? self.completed
        )
    }
}

/// Todo 생성 데이터 (ID가 없는 상태)
struct TodoCreationData: Sendable {
    let userId: Int
    let title: String
    let completed: Bool
}

