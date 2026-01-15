import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("language") var currentLanguage: Language = .english
    
    func localized(_ key: String) -> String {
        return LocalizationManager.shared.localized(key, using: currentLanguage)
    }
}
