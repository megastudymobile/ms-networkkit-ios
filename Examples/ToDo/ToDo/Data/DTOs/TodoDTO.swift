import Foundation
import MegaNetworkKit

/// Todo Data Transfer Object
struct TodoDTO: Responsable, Encodable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

// MARK: - Domain Mapping

extension TodoDTO {
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

struct TodoCreationDTO: Encodable, Sendable {
    let userId: Int
    let title: String
    let completed: Bool
}

extension TodoCreationData {
    func toDTO() -> TodoCreationDTO {
        TodoCreationDTO(
            userId: userId,
            title: title,
            completed: completed
        )
    }
}

