import Foundation
import SwiftData

@Model
final class Lecture {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var transcript: String
    var summary: String
    var noteSections: [String]
    var audioResourcePath: String?
    var slideResourcePath: String?
    var createdFromUpload: Bool
    @Relationship(inverse: \Class.lectures) var course: Class?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        transcript: String = "",
        summary: String = "",
        noteSections: [String] = [],
        audioResourcePath: String? = nil,
        slideResourcePath: String? = nil,
        createdFromUpload: Bool = false,
        course: Class? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.transcript = transcript
        self.summary = summary
        self.noteSections = noteSections
        self.audioResourcePath = audioResourcePath
        self.slideResourcePath = slideResourcePath
        self.createdFromUpload = createdFromUpload
        self.course = course
    }

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    var notesPreview: String {
        if noteSections.isEmpty {
            return summary.isEmpty ? "No notes captured yet." : summary
        }
        return noteSections.first ?? summary
    }
}

extension Lecture {
    static func makeMock(className: String, offset: Int) -> Lecture {
        let baseDate = Date().addingTimeInterval(Double(-offset) * 86_400)
        let sections = [
            "Key concepts of \(className) lecture \(offset + 1)",
            "Important theorem recap",
            "Ideas for project iteration"
        ]
        let summary = "Lecture \(offset + 1) looked at \(className.lowercased()) foundations with emphasis on applied practice."
        return Lecture(
            title: "Lecture \(offset + 1)",
            date: baseDate,
            transcript: "Transcript placeholder for lecture \(offset + 1)",
            summary: summary,
            noteSections: sections,
            audioResourcePath: "recording_\(offset + 1).m4a",
            slideResourcePath: "slides_\(offset + 1).pdf",
            createdFromUpload: offset % 2 == 0
        )
    }
}

extension Lecture: Identifiable {}
