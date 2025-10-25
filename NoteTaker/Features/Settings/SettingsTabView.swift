import SwiftUI

struct SettingsTabView: View {
    @State private var displayName: String = "Taylor Swift"
    @State private var apiKey: String = ""
    @State private var selectedModel: AIModel = .gpt4o
    @State private var useICloudSync: Bool = true
    @State private var defaultNoteLength: Double = 2
    @State private var remindersEnabled: Bool = false

    var body: some View {
        Form {
            Section("Profile") {
                HStack(spacing: 16) {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: 48)))
                    TextField("Your name", text: $displayName)
                }
                Text("Avatar customization will hook into Contacts or Photos APIs in a future update.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("AI Configuration") {
                Picker("Model", selection: $selectedModel) {
                    ForEach(AIModel.allCases) { model in
                        Text(model.label).tag(model)
                    }
                }
                SecureField("API Key", text: $apiKey)
                    .textContentType(.password)
                Text("Store keys securely using the Keychain. Use this screen to switch between providers or sandbox environments.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Sync") {
                Toggle("Sync with iCloud", isOn: $useICloudSync)
                Button("Export Data Snapshot") {
                    // Export action will serialize SwiftData records for manual backup.
                }
            } footer: {
                Text("Add background tasks here to handle periodic sync checks and share progress with other devices.")
            }

            Section("Study Preferences") {
                VStack(alignment: .leading) {
                    Text("Default summary detail")
                    Slider(value: $defaultNoteLength, in: 1...5, step: 1) {
                        Text("Detail level")
                    } minimumValueLabel: {
                        Text("Brief")
                    } maximumValueLabel: {
                        Text("Deep dive")
                    }
                }
                Toggle("Study reminders", isOn: $remindersEnabled)
            } footer: {
                Text("Future: integrate with EventKit to schedule study reminders and connect to Focus Filters.")
            }
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(.regularMaterial)
    }
}

private enum AIModel: String, CaseIterable, Identifiable {
    case gpt4o
    case llamaNext
    case custom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .gpt4o:
            return "GPT-4o"
        case .llamaNext:
            return "Llama Next"
        case .custom:
            return "Custom Endpoint"
        }
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsTabView()
    }
}
