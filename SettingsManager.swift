import Foundation
import Observation

@MainActor
@Observable
final class SettingsManager {
    @MainActor
    static let shared = SettingsManager()

    var currentLanguage: Language {
        didSet { userDefaults.set(currentLanguage.rawValue, forKey: "language") }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let raw = userDefaults.string(forKey: "language") ?? Language.english.rawValue
        self.currentLanguage = Language(rawValue: raw) ?? .english
    }

    func localized(_ key: String) -> String {
        LocalizationManager.shared.localized(key, using: currentLanguage)
    }
}
