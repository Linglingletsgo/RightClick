import XCTest
@testable import RightClickCore

final class FinderActionFormattingTests: XCTestCase {
    func testFormatsSelectedPathsOnePerLine() {
        let urls = [
            URL(fileURLWithPath: "/Users/example/a.txt"),
            URL(fileURLWithPath: "/Users/example/Folder", isDirectory: true)
        ]

        XCTAssertEqual(
            FinderActionFormatting.paths(for: urls),
            "/Users/example/a.txt\n/Users/example/Folder"
        )
    }

    func testFormatsSelectedNamesOnePerLine() {
        let urls = [
            URL(fileURLWithPath: "/Users/example/a.txt"),
            URL(fileURLWithPath: "/Users/example/Folder", isDirectory: true)
        ]

        XCTAssertEqual(
            FinderActionFormatting.names(for: urls),
            "a.txt\nFolder"
        )
    }
}
