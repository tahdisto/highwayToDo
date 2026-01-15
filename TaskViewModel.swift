import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoItem] = [] {
        didSet {
            saveTasks()
        }
    }
    
    private let tasksKey = "savedTasks"
    private let dateKey = "lastSavedDate"
    
    init() {
        loadTasks()
        checkAndResetTasks()
    }
    
    func addTask(title: String, priority: Priority) {
        let newTask = TodoItem(title: title, priority: priority)
        tasks.append(newTask)
        // Sort by priority (High -> Low)
        sortTasks()
    }
    
    func toggleCompletion(for task: TodoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func sortTasks() {
        tasks.sort {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted // Uncompleted first
            }
            if $0.priority != $1.priority {
                // Custom order for priority if needed, but enum follows order of definition or we can be explicit
                // Let's be explicit: High < Medium < Low (if we want High first, we might need comparable or custom logic)
                return priorityValue($0.priority) > priorityValue($1.priority)
            }
            return $0.createdAt < $1.createdAt
        }
    }
    
    private func priorityValue(_ p: Priority) -> Int {
        switch p {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    // MARK: - Persistence & Reset
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            tasks = decoded
        }
    }
    
    private func checkAndResetTasks() {
        let lastDate = UserDefaults.standard.object(forKey: dateKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDateInToday(lastDate) {
            // It's a new day! Reset tasks.
            print("New day detected. Resetting tasks.")
            tasks.removeAll()
            // Note: We save immediately to update the date, but also empty list
            saveTasks()
        }
    }
}
