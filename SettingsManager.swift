import AppKit
import Observation

enum AppTheme: String, CaseIterable, Codable, Sendable {
    case system
    case light
    case dark
}

@MainActor
@Observable
final class SettingsManager {
    @MainActor
    static let shared = SettingsManager()

    var currentLanguage: Language {
        didSet { userDefaults.set(currentLanguage.rawValue, forKey: "language") }
    }

    var currentTheme: AppTheme {
        didSet {
            userDefaults.set(currentTheme.rawValue, forKey: "theme")
            applyTheme()
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let raw = userDefaults.string(forKey: "language") ?? Language.english.rawValue
        self.currentLanguage = Language(rawValue: raw) ?? .english
        let themeRaw = userDefaults.string(forKey: "theme") ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: themeRaw) ?? .system
        applyTheme()
    }

    func localized(_ key: String) -> String {
        LocalizationManager.shared.localized(key, using: currentLanguage)
    }

    private func applyTheme() {
        let appearance: NSAppearance? = switch currentTheme {
        case .system: nil
        case .light:  NSAppearance(named: .aqua)
        case .dark:   NSAppearance(named: .darkAqua)
        }
        NSApp.appearance = appearance
        for window in NSApp.windows {
            window.appearance = appearance
        }
    }
}
