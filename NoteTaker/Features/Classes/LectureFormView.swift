import SwiftUI
import SwiftData

struct LectureFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var course: Class
    @Bindable var lecture: Lecture

    init(course: Class, lecture: Lecture? = nil) {
        self.course = course
        self.lecture = lecture ?? Lecture(title: "New Lecture", date: .now, summary: "", noteSections: [], createdFromUpload: false, course: course)
    }

    var body: some View {
        Form {
            Section("Metadata") {
                TextField("Title", text: $lecture.title)
                DatePicker("Date", selection: $lecture.date, displayedComponents: [.date, .hourAndMinute])
                Toggle("Created from upload", isOn: $lecture.createdFromUpload)
            }

            Section("Attachments") {
                TextField("Audio file", text: Binding($lecture.audioResourcePath, replacingNilWith: ""))
                TextField("Slide file", text: Binding($lecture.slideResourcePath, replacingNilWith: ""))
                TextField("Summary", text: $lecture.summary, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }

            Section("Notes") {
                if lecture.noteSections.isEmpty {
                    ContentUnavailableView("No notes", systemImage: "text.badge.plus", description: Text("Add notes generated from AI or typed manually."))
                } else {
                    ForEach(Array(lecture.noteSections.indices), id: \.self) { index in
                        TextField("Note #\(index + 1)", text: $lecture.noteSections[index], axis: .vertical)
                    }
                    .onDelete { indexSet in
                        lecture.noteSections.remove(atOffsets: indexSet)
                    }
                }
                Button {
                    lecture.noteSections.append("")
                } label: {
                    Label("Add Note", systemImage: "plus")
                }
            }

            Section("Transcript") {
                TextEditor(text: $lecture.transcript)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(lecture.persistentModelID == nil ? "New Lecture" : "Edit Lecture")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
            }
        }
    }

    private func save() {
        if lecture.persistentModelID == nil {
            course.lectures.append(lecture)
            modelContext.insert(lecture)
        }
        course.touchUpdatedAt()
        try? modelContext.save()
        dismiss()
    }
}

private extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith placeholder: String) {
        self.init(get: { source.wrappedValue ?? placeholder }, set: { newValue in
            source.wrappedValue = newValue.isEmpty ? nil : newValue
        })
    }
}
