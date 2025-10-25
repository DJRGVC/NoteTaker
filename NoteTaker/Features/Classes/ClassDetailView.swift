import SwiftUI
import SwiftData

struct ClassDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var course: Class

    @State private var quickNoteText: String = ""
    @State private var showingLectureForm = false
    @State private var lectureToEdit: Lecture?

    var body: some View {
        List {
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.descriptionText.isEmpty ? "No overview yet." : course.descriptionText)
                    Label("Instructor: \(course.instructor)", systemImage: "person.text.rectangle")
                        .foregroundStyle(.secondary)
                    Label(course.summary, systemImage: "clock")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .padding(.vertical, 4)
            }

            Section("Lectures") {
                if course.sortedLectures.isEmpty {
                    ContentUnavailableView(
                        "No Lectures",
                        systemImage: "waveform.badge.plus",
                        description: Text("Capture a quick note below or use the toolbar to import audio/slides.")
                    )
                } else {
                    ForEach(course.sortedLectures) { lecture in
                        NavigationLink(value: lecture) {
                            LectureRow(lecture: lecture)
                        }
                        .contextMenu {
                            Button("Edit title") { lectureToEdit = lecture }
                            Button(role: .destructive) {
                                delete(lecture)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { course.sortedLectures[$0] }.forEach(delete)
                    }
                }
            }

            Section("Quick Note") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Capture a moment from today...", text: $quickNoteText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                    Button(action: saveQuickNote) {
                        Label("Save Note", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(quickNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(course.name)
        .navigationDestination(for: Lecture.self, destination: LectureDetailView.init)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    // This button should trigger audio recording flow for lecture generation.
                    showingLectureForm = true
                } label: {
                    Label("New Lecture", systemImage: "plus")
                }
                Button {
                    // Hook up to document picker for PDF slide ingestion.
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down.on.square")
                }
            }
        }
        .sheet(isPresented: $showingLectureForm) {
            NavigationStack {
                LectureFormView(course: course)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $lectureToEdit) { lecture in
            NavigationStack {
                LectureFormView(course: course, lecture: lecture)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func saveQuickNote() {
        guard !quickNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let lecture = Lecture(
            title: "Quick Note \(Date.now.formatted(date: .numeric, time: .shortened))",
            date: .now,
            summary: quickNoteText,
            noteSections: [quickNoteText],
            createdFromUpload: false,
            course: course
        )
        modelContext.insert(lecture)
        course.lectures.append(lecture)
        course.touchUpdatedAt()
        quickNoteText = ""
        try? modelContext.save()
    }

    private func delete(_ lecture: Lecture) {
        modelContext.delete(lecture)
        course.lectures.removeAll { $0.id == lecture.id }
        course.touchUpdatedAt()
        try? modelContext.save()
    }
}

private struct LectureRow: View {
    @Bindable var lecture: Lecture

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lecture.title)
                    .font(.headline)
                Spacer()
                Text(lecture.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(lecture.notesPreview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview("Class Detail") {
    NavigationStack {
        if let course = try? PreviewBootstrap.previewContainer.mainContext.fetch(FetchDescriptor<Class>()).first {
            ClassDetailView(course: course)
        }
    }
    .modelContainer(PreviewBootstrap.previewContainer)
}
