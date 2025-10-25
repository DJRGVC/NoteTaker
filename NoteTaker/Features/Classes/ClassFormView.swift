import SwiftUI
import SwiftData

struct ClassFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let courseToEdit: Class?

    @State private var name: String
    @State private var instructor: String
    @State private var description: String
    @State private var colorHex: String

    init(course: Class? = nil) {
        self.courseToEdit = course
        _name = State(initialValue: course?.name ?? "")
        _instructor = State(initialValue: course?.instructor ?? "")
        _description = State(initialValue: course?.descriptionText ?? "")
        _colorHex = State(initialValue: course?.colorHex ?? "#4F46E5")
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Instructor", text: $instructor)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }

            Section("Appearance") {
                TextField("Color Hex", text: $colorHex)
                ColorSwatch(hex: $colorHex)
            }

            Section(footer: Text("Connect AI endpoints to stream transcripts from uploaded audio or PDF parsing.")) {
                Text("Future fields like syllabus, meeting links, or assignment templates can live here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(courseToEdit == nil ? "New Class" : "Edit Class")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        if let courseToEdit {
            courseToEdit.name = name
            courseToEdit.instructor = instructor
            courseToEdit.descriptionText = description
            courseToEdit.colorHex = colorHex
            courseToEdit.touchUpdatedAt()
        } else {
            let newCourse = Class(name: name, instructor: instructor, descriptionText: description, colorHex: colorHex)
            modelContext.insert(newCourse)
        }
        try? modelContext.save()
        dismiss()
    }
}

private struct ColorSwatch: View {
    @Binding var hex: String

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: hex))
            .frame(height: 44)
            .overlay(alignment: .bottomTrailing) {
                Button("Randomize") {
                    hex = ["#6366F1", "#F97316", "#22C55E", "#0EA5E9", "#EC4899"].randomElement() ?? hex
                }
                .buttonStyle(.borderedProminent)
                .padding(8)
            }
    }
}

#Preview("Class Form") {
    NavigationStack {
        ClassFormView(course: Class.makeMock())
    }
    .modelContainer(PreviewBootstrap.previewContainer)
}
