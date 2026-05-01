// swift-tools-version: 6.0
import PackageDescription

// This manifest exists solely to run `swift test`.
// The app bundle is still built via build.sh using swiftc directly.
// Only the pure-logic files (no SwiftUI views, no @main) are included here.

let package = Package(
    name: "HighwayToDo",
    platforms: [.macOS(.v14)],  // @Observable requires macOS 14+
    targets: [
        .target(
            name: "HighwayToDoCore",
            path: ".",
            exclude: [
                "HighwayTodoApp.swift",
                "ContentView.swift",
                "SettingsView.swift",
                "Info.plist",
                "build.sh",
                "README.md",
                "app_icon.png",
                "menubar_icon.png",
                "Highway To-Do.app",
                "Tests",
                ".vscode"
            ],
            sources: [
                "TaskModel.swift",
                "TaskViewModel.swift",
                "LocalizationManager.swift",
                "SettingsManager.swift"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "HighwayToDoTests",
            dependencies: ["HighwayToDoCore"],
            path: "Tests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
