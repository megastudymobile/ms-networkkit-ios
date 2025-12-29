import Foundation
import MegaNetworkKit

/// Todo Data Transfer Object
///
/// JSONPlaceholder API 응답을 매핑하는 DTO입니다.
/// Data Layer에서만 사용되며, Domain Entity로 변환됩니다.
struct TodoDTO: Responsable, Encodable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

// MARK: - Domain Mapping

extension TodoDTO {
    /// DTO → Domain Entity 변환
    func toDomain() -> Todo {
        Todo(
            id: id,
            userId: userId,
            title: title,
            completed: completed
        )
    }
}

extension Todo {
    /// Domain Entity → DTO 변환 (업데이트용)
    func toDTO() -> TodoDTO {
        TodoDTO(
            id: id,
            userId: userId,
            title: title,
            completed: completed
        )
    }
}

// MARK: - Creation DTO

/// Todo 생성 요청 DTO
struct TodoCreationDTO: Encodable, Sendable {
    let userId: Int
    let title: String
    let completed: Bool
}

extension TodoCreationData {
    /// Creation Data → DTO 변환
    func toDTO() -> TodoCreationDTO {
        TodoCreationDTO(
            userId: userId,
            title: title,
            completed: completed
        )
    }
}

