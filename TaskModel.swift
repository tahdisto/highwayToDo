import Foundation

enum Priority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var priority: Priority
    var isCompleted: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, priority: Priority, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
