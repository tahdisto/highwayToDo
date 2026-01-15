import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    // Fixed Gradient for Settings Window
    private let settingsGradient: [Color] = [
        Color(red: 0.2, green: 0.1, blue: 0.4),
        Color(red: 0.1, green: 0.1, blue: 0.3)
    ]
    
    var body: some View {
        ZStack {
            // Base Material
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Tint Gradient
            LinearGradient(gradient: Gradient(colors: settingsGradient), startPoint: .top, endPoint: .bottom)
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                    Text(settings.localized("settings"))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.primary)
                .padding(.top, 20)
                
                // Language Selection
                VStack(alignment: .leading, spacing: 10) {
                    Label(settings.localized("language"), systemImage: "globe")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Language", selection: $settings.currentLanguage) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                Spacer()
                
                // Info
                Text("Highway To-Do v. 0.9 Pre-Release")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}
