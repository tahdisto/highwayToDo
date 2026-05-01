import Foundation
import Observation

// Bug fixes vs v0.9:
// 1. toggleCompletion now re-sorts tasks (completed items were not moving to bottom)
// 2. loadTasks() no longer triggers saveTasks() via didSet (init flag guard)
// 3. addTask() validates and trims input at the model layer
// 4. Removed stray print() call

@MainActor
@Observable
final class TaskViewModel {
    private(set) var tasks: [TodoItem] = []

    private let userDefaults: UserDefaults
    private let tasksKey = "savedTasks"
    private let dateKey  = "lastSavedDate"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadTasks()
        checkAndResetTasks()
    }

    func addTask(title: String, priority: Priority) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        tasks.append(TodoItem(title: trimmed, priority: priority))
        sortTasks()
        saveTasks()
    }

    func toggleCompletion(for task: TodoItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        sortTasks()   // fix: was missing in v0.9
        saveTasks()
    }

    func deleteTask(at offsets: IndexSet) {
        // remove(atOffsets:) is a SwiftUI extension; iterate in reverse to keep indices valid
        for index in offsets.sorted().reversed() {
            tasks.remove(at: index)
        }
        saveTasks()
    }

    // MARK: - Private

    private func sortTasks() {
        tasks.sort {
            if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
            if $0.priority    != $1.priority    { return $0.priority > $1.priority }
            return $0.createdAt < $1.createdAt
        }
    }

    private func saveTasks() {
        guard let encoded = try? JSONEncoder().encode(tasks) else { return }
        userDefaults.set(encoded, forKey: tasksKey)
        userDefaults.set(Date(), forKey: dateKey)
    }

    private func loadTasks() {
        guard
            let data    = userDefaults.data(forKey: tasksKey),
            let decoded = try? JSONDecoder().decode([TodoItem].self, from: data)
        else { return }
        tasks = decoded   // no didSet → no spurious saveTasks() call
    }

    private func checkAndResetTasks() {
        let lastDate = userDefaults.object(forKey: dateKey) as? Date ?? .distantPast
        guard !Calendar.current.isDateInToday(lastDate) else { return }
        tasks.removeAll()
        saveTasks()
    }
}