import Foundation

enum Language: String, CaseIterable, Codable {
    case english = "en"
    case russian = "ru"
    case greek = "el"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .greek: return "Ελληνικά"
        }
    }
}

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private let translations: [String: [Language: String]] = [
        "newTaskPlaceholder": [
            .english: "New task for today...",
            .russian: "Новая задача на сегодня...",
            .greek: "Νέα εργασία για σήμερα..."
        ],
        "priority": [
            .english: "Priority",
            .russian: "Приоритет",
            .greek: "Προτεραιότητα"
        ],
        "priorityHigh": [
            .english: "High",
            .russian: "Высокий",
            .greek: "Υψηλή"
        ],
        "priorityMedium": [
            .english: "Medium",
            .russian: "Средний",
            .greek: "Μεσαία"
        ],
        "priorityLow": [
            .english: "Low",
            .russian: "Низкий",
            .greek: "Χαμηλή"
        ],
        "noTasksTitle": [
            .english: "No tasks for today. Chill!",
            .russian: "На сегодня задач нет. Отдыхай!",
            .greek: "Καμία εργασία για σήμερα. Χαλάρωσε!"
        ],
        "quit": [
            .english: "Quit",
            .russian: "Выйти",
            .greek: "Έξοδος"
        ],
        "settings": [
            .english: "Settings",
            .russian: "Настройки",
            .greek: "Ρυθμίσεις"
        ],
        "language": [
            .english: "Language",
            .russian: "Язык",
            .greek: "Γλώσσα"
        ],
        "back": [
            .english: "Back",
            .russian: "Назад",
            .greek: "Πίσω"
        ]
    ]
    
    func localized(_ key: String, using language: Language) -> String {
        return translations[key]?[language] ?? key
    }
}
