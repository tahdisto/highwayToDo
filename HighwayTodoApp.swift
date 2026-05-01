import SwiftUI
import AppKit

@main
struct HighwayTodoApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(SettingsManager.shared)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView()
                .environment(SettingsManager.shared)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 400)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if let image = loadMenuBarImage() {
            Image(nsImage: image)
        } else {
            Image(systemName: "checklist")
        }
    }

    private func loadMenuBarImage() -> NSImage? {
        guard
            let path  = Bundle.main.path(forResource: "menubar_icon", ofType: "png"),
            let image = NSImage(contentsOfFile: path)
        else { return nil }
        image.isTemplate = true
        image.size = NSSize(width: 18, height: 18)
        return image
    }
}
