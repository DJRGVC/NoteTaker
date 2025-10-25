import Foundation
import SwiftData

@Model
final class Class {
    @Attribute(.unique) var id: UUID
    var name: String
    var instructor: String
    var descriptionText: String
    var colorHex: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Lecture.course) var lectures: [Lecture]

    init(
        id: UUID = UUID(),
        name: String,
        instructor: String,
        descriptionText: String = "",
        colorHex: String = "#4F46E5",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        lectures: [Lecture] = []
    ) {
        self.id = id
        self.name = name
        self.instructor = instructor
        self.descriptionText = descriptionText
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lectures = lectures
    }

    var sortedLectures: [Lecture] {
        lectures.sorted { $0.date > $1.date }
    }

    var summary: String {
        if let latest = sortedLectures.first {
            return "Last lecture on \(latest.date.formatted(date: .abbreviated, time: .shortened))"
        } else if descriptionText.isEmpty {
            return "No lectures yet. Start by adding one!"
        } else {
            return descriptionText
        }
    }

    func touchUpdatedAt() {
        updatedAt = .now
    }
}

extension Class {
    static func makeMock(
        name: String = "Introduction to Machine Learning",
        instructor: String = "Dr. Rivera",
        descriptionText: String = "Explore supervised, unsupervised, and reinforcement learning concepts.",
        colorHex: String = "#6366F1",
        lectureCount: Int = 3
    ) -> Class {
        let course = Class(
            name: name,
            instructor: instructor,
            descriptionText: descriptionText,
            colorHex: colorHex,
            createdAt: .now.addingTimeInterval(-86400 * 7),
            updatedAt: .now
        )

        course.lectures = (0..<lectureCount).map { index in
            Lecture.makeMock(className: name, offset: index)
        }

        course.lectures.forEach { $0.course = course }
        return course
    }

    static func mockClasses() -> [Class] {
        [
            Class.makeMock(),
            Class.makeMock(
                name: "Designing Intelligent Interfaces",
                instructor: "Prof. Lee",
                descriptionText: "Discusses multimodal UI, accessibility, and adaptive layouts for knowledge workers.",
                colorHex: "#F97316",
                lectureCount: 4
            ),
            Class.makeMock(
                name: "Neuroscience of Learning",
                instructor: "Dr. Gómez",
                descriptionText: "Connects neurobiology with study habits and learning science.",
                colorHex: "#10B981",
                lectureCount: 2
            )
        ]
    }

    static func seedPreviewData(into context: ModelContext) {
        do {
            let existing = try context.fetch(FetchDescriptor<Class>())
            existing.forEach(context.delete)
            mockClasses().forEach(context.insert)
            try context.save()
        } catch {
            assertionFailure("Failed to seed preview data: \(error)")
        }
    }
}

extension Class: Identifiable {}
