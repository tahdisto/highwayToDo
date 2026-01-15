import SwiftUI

@main
struct HighwayTodoApp: App {
    @StateObject private var settings = SettingsManager.shared
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(settings)
        } label: {
            if let iconPath = Bundle.main.path(forResource: "menubar_icon", ofType: "png"),
               let nsImage = NSImage(contentsOfFile: iconPath) {
                let _ = {
                    nsImage.isTemplate = true
                    nsImage.size = NSSize(width: 18, height: 18)
                }()
                Image(nsImage: nsImage)
            } else {
                Image(systemName: "checklist")
            }
        }
        .menuBarExtraStyle(.window)
        
        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(settings)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 400)
    }
}
