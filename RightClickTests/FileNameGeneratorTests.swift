import XCTest
@testable import RightClickCore

final class FileNameGeneratorTests: XCTestCase {
    func testReturnsUntitledFileWhenNoCollisionExists() {
        let directory = URL(fileURLWithPath: "/Users/example/Desktop", isDirectory: true)

        let result = FileNameGenerator.nextAvailableFileURL(
            in: directory,
            fileExtension: "md",
            fileExists: { _ in false }
        )

        XCTAssertEqual(result.lastPathComponent, "Untitled.md")
    }

    func testIncrementsUntitledFileNameWhenCollisionExists() {
        let directory = URL(fileURLWithPath: "/Users/example/Desktop", isDirectory: true)
        let existingNames: Set<String> = ["Untitled.md", "Untitled 2.md"]

        let result = FileNameGenerator.nextAvailableFileURL(
            in: directory,
            fileExtension: "md",
            fileExists: { existingNames.contains($0.lastPathComponent) }
        )

        XCTAssertEqual(result.lastPathComponent, "Untitled 3.md")
    }
}
