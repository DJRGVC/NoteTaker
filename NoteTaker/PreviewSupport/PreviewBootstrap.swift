import SwiftData

enum PreviewBootstrap {
    static var previewContainer: ModelContainer = {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Schema([Class.self, Lecture.self]), configurations: configuration)
            Class.seedPreviewData(into: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
