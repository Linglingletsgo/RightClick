import XCTest
@testable import RightClickCore

final class MenuContextResolverTests: XCTestCase {
    func testSelectedItemsContextRequiresSelectedURLsInWatchedFolder() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let selected = [home.appendingPathComponent("file.txt")]

        let context = MenuContextResolver.resolve(
            menuKind: .items,
            selectedURLs: selected,
            targetedURL: home,
            watchedFolders: [home]
        )

        XCTAssertEqual(context, .selectedItems(selected))
    }

    func testContainerContextRequiresNoSelectionInWatchedFolder() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let folder = home.appendingPathComponent("Desktop", isDirectory: true)

        let context = MenuContextResolver.resolve(
            menuKind: .container,
            selectedURLs: [],
            targetedURL: folder,
            watchedFolders: [home]
        )

        XCTAssertEqual(context, .container(folder))
    }

    func testContainerContextIgnoresStaleSelection() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let folder = home.appendingPathComponent("Desktop", isDirectory: true)
        let selected = [folder.appendingPathComponent("file.txt")]

        let context = MenuContextResolver.resolve(
            menuKind: .container,
            selectedURLs: selected,
            targetedURL: folder,
            watchedFolders: [home]
        )

        XCTAssertEqual(context, .container(folder))
    }

    func testItemsContextFallsBackToContainerWhenSelectionIsOutsideTargetedDirectory() {
        let mobileDocuments = URL(fileURLWithPath: "/Users/example/Library/Mobile Documents", isDirectory: true)
        let cloudDocs = mobileDocuments.appendingPathComponent("com~apple~CloudDocs", isDirectory: true)
        let staleSelection = [
            mobileDocuments
                .appendingPathComponent("iCloud~com~example~App", isDirectory: true)
                .appendingPathComponent("Documents", isDirectory: true)
        ]

        let context = MenuContextResolver.resolve(
            menuKind: .items,
            selectedURLs: staleSelection,
            targetedURL: cloudDocs,
            watchedFolders: [mobileDocuments]
        )

        XCTAssertEqual(context, .container(cloudDocs))
    }

    func testReturnsUnsupportedOutsideWatchedFolders() {
        let watched = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let outside = URL(fileURLWithPath: "/Volumes/External/file.txt")

        let context = MenuContextResolver.resolve(
            menuKind: .items,
            selectedURLs: [outside],
            targetedURL: outside,
            watchedFolders: [watched]
        )

        XCTAssertEqual(context, .unsupported)
    }
}
