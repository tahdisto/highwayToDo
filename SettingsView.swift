import SwiftUI

struct SettingsView: View {
    @Environment(SettingsManager.self) private var settings

    private let ambientGradient = LinearGradient(
        colors: [Color(red: 0.20, green: 0.10, blue: 0.40), Color(red: 0.10, green: 0.10, blue: 0.30)],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        // @Bindable needed to derive two-way bindings from an @Observable environment value
        @Bindable var settings = settings

        ZStack {
            ambientGradient
                .opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                    Text(settings.localized("settings"))
                        .font(.title2.bold())
                }
                .foregroundStyle(.primary)
                .padding(.top, 20)

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
                .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()

                Text("Highway To-Do v1.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}

#Preview {
    SettingsView()
        .environment(SettingsManager())
}
