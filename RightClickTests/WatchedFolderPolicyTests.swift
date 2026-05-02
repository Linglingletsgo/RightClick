import XCTest
@testable import RightClickCore

final class WatchedFolderPolicyTests: XCTestCase {
    func testAllowsHomeDirectory() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

        XCTAssertTrue(WatchedFolderPolicy.allowsWatching(home))
    }

    func testRejectsExternalVolumeRoot() {
        let volume = URL(fileURLWithPath: "/Volumes/AnyDriveName", isDirectory: true)

        XCTAssertFalse(WatchedFolderPolicy.allowsWatching(volume))
    }

    func testAllowsFolderInsideExternalVolume() {
        let folder = URL(fileURLWithPath: "/Volumes/AnyDriveName/Projects", isDirectory: true)

        XCTAssertTrue(WatchedFolderPolicy.allowsWatching(folder))
    }

    func testRejectsICloudDriveLocation() {
        let folder = URL(fileURLWithPath: "/Users/example/Library/Mobile Documents/com~apple~CloudDocs", isDirectory: true)

        XCTAssertFalse(WatchedFolderPolicy.allowsWatching(folder))
    }

    func testRejectsCloudStorageLocation() {
        let folder = URL(fileURLWithPath: "/Users/example/Library/CloudStorage/OneDrive", isDirectory: true)

        XCTAssertFalse(WatchedFolderPolicy.allowsWatching(folder))
    }

    func testFiltersExternalVolumeRootFromWatchedFolders() {
        let home = WatchedFolder(
            name: "Home",
            url: URL(fileURLWithPath: "/Users/example", isDirectory: true),
            isDefault: true
        )
        let volume = WatchedFolder(
            name: "AnyDriveName",
            url: URL(fileURLWithPath: "/Volumes/AnyDriveName", isDirectory: true)
        )
        let folder = WatchedFolder(
            name: "Projects",
            url: URL(fileURLWithPath: "/Volumes/AnyDriveName/Projects", isDirectory: true)
        )

        let filtered = WatchedFolderPolicy.allowedFolders(from: [home, volume, folder])

        XCTAssertEqual(filtered, [home, folder])
    }
}
