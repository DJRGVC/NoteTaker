import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .classes

    enum Tab: Hashable {
        case classes
        case learn
        case settings

        var label: some View {
            switch self {
            case .classes:
                Label("Classes", systemImage: "books.vertical")
            case .learn:
                Label("Learn", systemImage: "brain.head.profile")
            case .settings:
                Label("Settings", systemImage: "gearshape")
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ClassesTabView()
            }
            .tabItem { Tab.classes.label }
            .tag(Tab.classes)

            NavigationStack {
                LearnTabView()
            }
            .tabItem { Tab.learn.label }
            .tag(Tab.learn)

            NavigationStack {
                SettingsTabView()
            }
            .tabItem { Tab.settings.label }
            .tag(Tab.settings)
        }
        .tint(.accentColor)
        .background(.ultraThinMaterial)
        .task {
            // Preload preview data in empty stores to make first launch friendlier.
            if (try? modelContext.fetch(FetchDescriptor<Class>(fetchLimit: 1))).flatMap({ $0.isEmpty }) ?? true {
                Class.seedPreviewData(into: modelContext)
            }
        }
    }
}

#Preview("Root") {
    ContentView()
        .modelContainer(PreviewBootstrap.previewContainer)
}
