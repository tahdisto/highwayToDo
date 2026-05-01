import Testing
import Foundation
@testable import HighwayToDoCore

// MARK: - Priority

@Suite("Priority")
struct PriorityTests {
    @Test func ordering() {
        #expect(Priority.high   > Priority.medium)
        #expect(Priority.medium > Priority.low)
        #expect(Priority.high   > Priority.low)
    }

    @Test func allCasesCount() {
        #expect(Priority.allCases.count == 3)
    }

    @Test func rawValues() {
        #expect(Priority.high.rawValue   == "High")
        #expect(Priority.medium.rawValue == "Medium")
        #expect(Priority.low.rawValue    == "Low")
    }

    @Test func roundTripCodable() throws {
        let encoded = try JSONEncoder().encode(Priority.high)
        let decoded = try JSONDecoder().decode(Priority.self, from: encoded)
        #expect(decoded == .high)
    }
}

// MARK: - TodoItem

@Suite("TodoItem")
struct TodoItemTests {
    @Test func defaultValues() {
        let item = TodoItem(title: "Test", priority: .medium)
        #expect(item.title == "Test")
        #expect(item.priority == .medium)
        #expect(!item.isCompleted)
    }

    @Test func uniqueIDs() {
        let a = TodoItem(title: "A", priority: .high)
        let b = TodoItem(title: "B", priority: .high)
        #expect(a.id != b.id)
    }

    @Test func roundTripCodable() throws {
        let original = TodoItem(title: "Buy groceries", priority: .high)
        let data     = try JSONEncoder().encode(original)
        let decoded  = try JSONDecoder().decode(TodoItem.self, from: data)
        #expect(decoded.id         == original.id)
        #expect(decoded.title      == original.title)
        #expect(decoded.priority   == original.priority)
        #expect(decoded.isCompleted == original.isCompleted)
    }
}

// MARK: - TaskViewModel

@Suite("TaskViewModel")
@MainActor
struct TaskViewModelTests {

    // Isolated UserDefaults suite so tests never touch real storage
    private func makeVM(suite: String = "test_\(UUID().uuidString)") -> TaskViewModel {
        let defaults = UserDefaults(suiteName: suite)!
        return TaskViewModel(userDefaults: defaults)
    }

    @Test func addTask() {
        let vm = makeVM()
        vm.addTask(title: "Write tests", priority: .high)
        #expect(vm.tasks.count == 1)
        #expect(vm.tasks[0].title    == "Write tests")
        #expect(vm.tasks[0].priority == .high)
    }

    @Test func addTaskTrimsWhitespace() {
        let vm = makeVM()
        vm.addTask(title: "  Spaced  ", priority: .medium)
        #expect(vm.tasks[0].title == "Spaced")
    }

    @Test func emptyTaskIsIgnored() {
        let vm = makeVM()
        vm.addTask(title: "   ", priority: .high)
        #expect(vm.tasks.isEmpty)
    }

    @Test func sortsByPriorityDescending() {
        let vm = makeVM()
        vm.addTask(title: "Low",    priority: .low)
        vm.addTask(title: "High",   priority: .high)
        vm.addTask(title: "Medium", priority: .medium)
        #expect(vm.tasks[0].priority == .high)
        #expect(vm.tasks[1].priority == .medium)
        #expect(vm.tasks[2].priority == .low)
    }

    @Test func completedTaskSortsToBottom() {
        let vm = makeVM()
        vm.addTask(title: "A", priority: .high)
        vm.addTask(title: "B", priority: .low)
        // tasks[0] is High (uncompleted) — complete it
        vm.toggleCompletion(for: vm.tasks[0])
        // Now Low (uncompleted) should be first, High (completed) last
        #expect(!vm.tasks[0].isCompleted)
        #expect(vm.tasks[1].isCompleted)
    }

    @Test func toggleCompletionFlips() {
        let vm = makeVM()
        vm.addTask(title: "Toggle me", priority: .medium)
        let id = vm.tasks[0].id

        vm.toggleCompletion(for: vm.tasks[0])
        #expect(vm.tasks.first(where: { $0.id == id })?.isCompleted == true)

        vm.toggleCompletion(for: vm.tasks.first(where: { $0.id == id })!)
        #expect(vm.tasks.first(where: { $0.id == id })?.isCompleted == false)
    }

    @Test func deleteTask() {
        let vm = makeVM()
        vm.addTask(title: "Delete me", priority: .low)
        vm.deleteTask(at: IndexSet(integer: 0))
        #expect(vm.tasks.isEmpty)
    }

    @Test func persistenceAcrossInstances() {
        let suite = "persist_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!

        let vm1 = TaskViewModel(userDefaults: defaults)
        vm1.addTask(title: "Persistent", priority: .high)

        let vm2 = TaskViewModel(userDefaults: defaults)
        #expect(vm2.tasks.count == 1)
        #expect(vm2.tasks[0].title == "Persistent")

        defaults.removePersistentDomain(forName: suite)
    }
}

// MARK: - LocalizationManager

@Suite("LocalizationManager")
struct LocalizationTests {
    let manager = LocalizationManager.shared

    @Test func englishTranslations() {
        #expect(manager.localized("quit",     using: .english) == "Quit")
        #expect(manager.localized("settings", using: .english) == "Settings")
        #expect(manager.localized("priority", using: .english) == "Priority")
    }

    @Test func russianTranslations() {
        #expect(manager.localized("quit",     using: .russian) == "Выйти")
        #expect(manager.localized("settings", using: .russian) == "Настройки")
    }

    @Test func greekTranslations() {
        #expect(manager.localized("quit",     using: .greek) == "Έξοδος")
        #expect(manager.localized("settings", using: .greek) == "Ρυθμίσεις")
    }

    @Test func missingKeyReturnsKey() {
        #expect(manager.localized("__nonexistent__", using: .english) == "__nonexistent__")
    }

    @Test func languageDisplayNames() {
        #expect(Language.english.displayName == "English")
        #expect(Language.russian.displayName == "Русский")
        #expect(Language.greek.displayName   == "Ελληνικά")
    }

    @Test func allLanguagesCovered() {
        let keys = ["quit", "settings", "priority", "language", "back",
                    "noTasksTitle", "priorityHigh", "priorityMedium", "priorityLow",
                    "newTaskPlaceholder"]
        for key in keys {
            for lang in Language.allCases {
                // If a translation is missing, localized() returns the key itself
                let result = manager.localized(key, using: lang)
                #expect(result != key, "Missing translation for key '\(key)' in \(lang)")
            }
        }
    }
}
