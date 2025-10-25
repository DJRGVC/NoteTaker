import XCTest
import SwiftData
@testable import NoteTaker

final class NoteTakerTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext { container.mainContext }

    override func setUpWithError() throws {
        container = try ModelContainer(for: Schema([Class.self, Lecture.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    override func tearDownWithError() throws {
        container = nil
    }

    func testCreateClass() throws {
        let course = Class(name: "Test", instructor: "Tester")
        context.insert(course)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Class>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Test")
    }

    func testUpdateLecture() throws {
        let course = Class.makeMock(lectureCount: 1)
        context.insert(course)
        try context.save()

        guard let lecture = course.lectures.first else {
            XCTFail("Lecture should exist")
            return
        }

        lecture.summary = "Updated summary"
        try context.save()

        let lectures = try context.fetch(FetchDescriptor<Lecture>())
        XCTAssertEqual(lectures.first?.summary, "Updated summary")
    }

    func testDeleteCourseCascades() throws {
        let course = Class.makeMock()
        context.insert(course)
        try context.save()

        XCTAssertFalse(course.lectures.isEmpty)
        context.delete(course)
        try context.save()

        let classes = try context.fetch(FetchDescriptor<Class>())
        XCTAssertTrue(classes.isEmpty)
        let lectures = try context.fetch(FetchDescriptor<Lecture>())
        XCTAssertTrue(lectures.isEmpty)
    }
}
