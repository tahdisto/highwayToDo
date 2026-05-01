import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(SettingsManager.self) private var settings
    @State private var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var selectedPriority: Priority = .medium
    @Environment(\.openWindow) private var openWindow

    // Ambient gradient gives Liquid Glass its purple-blue iridescence
    private let ambientGradient = LinearGradient(
        colors: [
            Color(red: 0.40, green: 0.10, blue: 0.80),
            Color(red: 0.10, green: 0.50, blue: 0.90),
            Color(red: 0.10, green: 0.80, blue: 0.70)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            ambientGradient
                .opacity(0.22)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                inputHeader
                taskContent
                footer
            }
        }
        .frame(width: 380)
    }

    // MARK: - Sections

    private var inputHeader: some View {
        HStack(spacing: 8) {
            TextField(settings.localized("newTaskPlaceholder"), text: $newTaskTitle)
                .textFieldStyle(.plain)
                .padding(10)
                .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                .onSubmit { addNewTask() }

            priorityPicker

            Button(action: addNewTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.primary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .glassEffect(in: Rectangle())
    }

    private var priorityPicker: some View {
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
    }

    @ViewBuilder
    private var taskContent: some View {
        if viewModel.tasks.isEmpty {
            emptyState
        } else {
            taskList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse)
            Text(settings.localized("noTasksTitle"))
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 250)
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRow(task: task) {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.toggleCompletion(for: task)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
            }
            .onDelete(perform: { offsets in
                withAnimation(.spring(duration: 0.25)) {
                    viewModel.deleteTask(at: offsets)
                }
            })
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .frame(height: 350)
    }

    private var footer: some View {
        HStack {
            Button {
                openWindow(id: "settings")
                NSApp.activate()           // NSApp.activate(ignoringOtherApps:) deprecated macOS 14
            } label: {
                Label(settings.localized("settings"), systemImage: "gearshape.fill")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .padding(6)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label(settings.localized("quit"), systemImage: "power")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect(in: Rectangle())
    }

    // MARK: - Actions

    private func addNewTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation(.spring(duration: 0.3)) {
            viewModel.addTask(title: newTaskTitle, priority: selectedPriority)
            newTaskTitle = ""
        }
    }
}

// MARK: - TaskRow

struct TaskRow: View {
    let task: TodoItem
    let toggleAction: () -> Void

    var body: some View {
        HStack {
            Button(action: toggleAction) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color.secondary : priorityColor)
                    .animation(.spring(duration: 0.2), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .font(.system(size: 15, weight: .medium, design: .rounded))

            Spacer()

            if !task.isCompleted {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high:   .red
        case .medium: .orange
        case .low:    .green
        }
    }
}

// MARK: - Priority localization helper (UI layer)

extension Priority {
    func localizedName(lang: Language) -> String {
        switch self {
        case .high:   LocalizationManager.shared.localized("priorityHigh",   using: lang)
        case .medium: LocalizationManager.shared.localized("priorityMedium", using: lang)
        case .low:    LocalizationManager.shared.localized("priorityLow",    using: lang)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(SettingsManager())
}
