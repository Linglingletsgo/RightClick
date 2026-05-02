import XCTest
@testable import RightClickCore

final class ObservedDirectoryProviderTests: XCTestCase {
    func testExpandsHomeToStandardUserDirectories() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let folders = [WatchedFolder(name: "Home", url: home, isDefault: true)]

        let paths = ObservedDirectoryProvider.directories(for: folders, homeDirectory: home).map(\.path)

        XCTAssertTrue(paths.contains("/Users/example"))
        XCTAssertTrue(paths.contains("/Users/example/Documents"))
        XCTAssertTrue(paths.contains("/Users/example/Desktop"))
        XCTAssertTrue(paths.contains("/Users/example/Downloads"))
        XCTAssertFalse(paths.contains("/Users/example/Library/Mobile Documents"))
        XCTAssertFalse(paths.contains("/Users/example/Library/CloudStorage"))
    }

    func testKeepsFolderInsideExternalVolume() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let externalFolder = URL(fileURLWithPath: "/Volumes/Drive/Projects", isDirectory: true)
        let folders = [WatchedFolder(name: "Projects", url: externalFolder, isDefault: false)]

        let paths = ObservedDirectoryProvider.directories(for: folders, homeDirectory: home).map(\.path)

        XCTAssertEqual(paths, ["/Volumes/Drive/Projects"])
    }

    func testRejectsExternalVolumeRoot() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)
        let externalRoot = URL(fileURLWithPath: "/Volumes/Drive", isDirectory: true)
        let folders = [WatchedFolder(name: "Drive", url: externalRoot, isDefault: false)]

        let paths = ObservedDirectoryProvider.directories(for: folders, homeDirectory: home).map(\.path)

        XCTAssertFalse(paths.contains("/Volumes/Drive"))
    }
}
