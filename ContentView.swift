import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.openWindow) var openWindow
    
    @State private var newTaskTitle: String = ""
    @State private var selectedPriority: Priority = .medium
    
    // Fixed Liquid Gradient Colors
    private let gradientColors: [Color] = [
        Color(red: 0.4, green: 0.1, blue: 0.8), // Purple
        Color(red: 0.1, green: 0.5, blue: 0.9), // Blue
        Color(red: 0.1, green: 0.8, blue: 0.7)  // Cyan
    ]
    
    var body: some View {
        ZStack {
            // 0. Frosted Glass Base
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // 1. Vibrant Liquid Tint
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.3)
                .ignoresSafeArea()
            
            // 2. Main Content
            VStack(spacing: 0) {
                // Header / Input Area
                VStack(spacing: 12) {
                    HStack {
                        TextField(settings.localized("newTaskPlaceholder"), text: $newTaskTitle)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                            .onSubmit {
                                addNewTask()
                            }
                        
                        // Centered Priority
                        Spacer(minLength: 5)
                        VStack(alignment: .center, spacing: 2) {
                            Text(settings.localized("priority"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Picker("Priority", selection: $selectedPriority) {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Text(priority.localizedName(lang: settings.currentLanguage)).tag(priority)
                                }
                            }
                            .frame(width: 90)
                            .labelsHidden()
                            .tint(.primary)
                            .scaleEffect(0.9)
                        }
                        Spacer(minLength: 5)
                        
                        Button(action: addNewTask) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Task List
                if viewModel.tasks.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 10)
                        Text(settings.localized("noTasksTitle"))
                            .font(.headline)
                        Spacer()
                    }
                    .frame(height: 250)
                } else {
                    List {
                        ForEach(viewModel.tasks) { task in
                            TaskRow(task: task, toggleAction: {
                                viewModel.toggleCompletion(for: task)
                            })
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.bottom, 6)
                        }
                        .onDelete(perform: viewModel.deleteTask)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .frame(height: 350)
                }
                
                // Footer
                HStack {
                    Button(action: {
                        openWindow(id: "settings")
                        NSApp.activate(ignoringOtherApps: true)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape.fill")
                                .font(.headline)
                            Text(settings.localized("settings"))
                                .font(.caption)
                        }
                        .foregroundStyle(.primary)
                        .padding(6)
                        .background(.ultraThinMaterial) 
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Label(settings.localized("quit"), systemImage: "power")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("q")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        .frame(width: 380)
    }
    
    private func addNewTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            viewModel.addTask(title: newTaskTitle, priority: selectedPriority)
            newTaskTitle = ""
        }
    }
}

struct TaskRow: View {
    let task: TodoItem
    let toggleAction: () -> Void
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        HStack {
            Button(action: toggleAction) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .white.opacity(0.5) : priorityColor(task.priority))
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
            
            Spacer()
            
            if !task.isCompleted {
                Circle()
                    .fill(priorityColor(task.priority))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

extension Priority {
    func localizedName(lang: Language) -> String {
        switch self {
        case .high: return LocalizationManager.shared.localized("priorityHigh", using: lang)
        case .medium: return LocalizationManager.shared.localized("priorityMedium", using: lang)
        case .low: return LocalizationManager.shared.localized("priorityLow", using: lang)
        }
    }
}
