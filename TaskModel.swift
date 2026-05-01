import Foundation

enum Priority: String, Codable, CaseIterable, Comparable, Sendable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    private var sortOrder: Int {
        switch self {
        case .high:   return 2
        case .medium: return 1
        case .low:    return 0
        }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct TodoItem: Identifiable, Codable, Sendable {
    let id: UUID
    var title: String
    var priority: Priority
    var isCompleted: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}