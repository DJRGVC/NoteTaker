import SwiftUI
import SwiftData

@main
struct NoteTakerApp: App {
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Class.self,
            Lecture.self
        ])

        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
