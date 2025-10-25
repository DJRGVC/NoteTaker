import SwiftUI
import SwiftData

struct LearnTabView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case flashcards = "Flashcards"
        case mcq = "MCQ Practice"
        case summaries = "Summaries"

        var id: String { rawValue }
    }

    @Query(sort: \Class.name) private var classes: [Class]

    @State private var mode: Mode = .flashcards
    @State private var selectedClass: Class?
    @State private var selectedLecture: Lecture?
    @State private var isGenerating = false

    var body: some View {
        VStack(spacing: 24) {
            segmentedControl
            classPicker
            lecturePicker
            contentArea
            regenerateButton
        }
        .padding()
        .navigationTitle("Learn")
        .background(.thinMaterial)
        .onAppear {
            if selectedClass == nil {
                selectedClass = classes.first
            }
            if selectedLecture == nil {
                selectedLecture = selectedClass?.sortedLectures.first
            }
        }
        .onChange(of: selectedClass) { _, newValue in
            selectedLecture = newValue?.sortedLectures.first
        }
    }

    private var segmentedControl: some View {
        Picker("Mode", selection: $mode) {
            ForEach(Mode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
    }

    private var classPicker: some View {
        Menu {
            ForEach(classes) { course in
                Button(action: { selectedClass = course }) {
                    if selectedClass?.id == course.id {
                        Label(course.name, systemImage: "checkmark")
                    } else {
                        Text(course.name)
                    }
                }
            }
        } label: {
            Label(selectedClass?.name ?? "Select Class", systemImage: "books.vertical")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private var lecturePicker: some View {
        Menu {
            ForEach(selectedClass?.sortedLectures ?? []) { lecture in
                Button(action: { selectedLecture = lecture }) {
                    if selectedLecture?.id == lecture.id {
                        Label(lecture.title, systemImage: "checkmark")
                    } else {
                        Text(lecture.title)
                    }
                }
            }
        } label: {
            Label(selectedLecture?.title ?? "Select Lecture", systemImage: "music.note.list")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(selectedClass == nil)
    }

    private var contentArea: some View {
        Group {
            switch mode {
            case .flashcards:
                LearnSectionView(title: "Flashcards", items: flashcardContent)
            case .mcq:
                LearnSectionView(title: "Multiple Choice", items: mcqContent)
            case .summaries:
                LearnSectionView(title: "Summaries", items: summaryContent)
            }
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }

    private var regenerateButton: some View {
        Button {
            Task {
                isGenerating = true
                defer { isGenerating = false }
                // Integrate with your AI orchestration layer here.
                try? await Task.sleep(for: .seconds(1.5))
            }
        } label: {
            Label(isGenerating ? "Regenerating…" : "Regenerate", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedClass == nil || isGenerating)
    }

    private var flashcardContent: [String] {
        guard let lecture = selectedLecture else {
            return ["Select a lecture to surface key flashcards."]
        }
        return lecture.noteSections.map { note in "Q: What about \(note.prefix(40))?\nA: Placeholder answer derived from AI." }
    }

    private var mcqContent: [String] {
        guard let lecture = selectedLecture else {
            return ["Choose a lecture to generate multiple choice practice."]
        }
        return [
            "Question based on \(lecture.title)\nA. Option 1\nB. Option 2\nC. Option 3\nD. Option 4",
            "Another prompt referencing \(lecture.summary.prefix(50))"
        ]
    }

    private var summaryContent: [String] {
        guard let lecture = selectedLecture else {
            return ["Pick a lecture to review auto-generated summaries."]
        }
        return [lecture.summary.isEmpty ? "Summary pending AI analysis." : lecture.summary]
    }
}

private struct LearnSectionView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.semibold))
            if items.isEmpty {
                Text("No content yet. Try regenerating once AI integration is wired up.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 3, y: 2)
    }
}

#Preview("Learn") {
    NavigationStack {
        LearnTabView()
    }
    .modelContainer(PreviewBootstrap.previewContainer)
}
