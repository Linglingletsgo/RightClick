import XCTest
@testable import RightClickCore

final class RightClickDefaultsTests: XCTestCase {
    func testDefaultConfigTargetsHomeAndEnablesRequiredFeatures() {
        let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

        let config = RightClickDefaults.config(homeDirectory: home)

        XCTAssertEqual(config.watchedFolders.map(\.url), [home])
        XCTAssertTrue(config.enabledItems.copyPath)
        XCTAssertTrue(config.enabledItems.copyName)
        XCTAssertTrue(config.enabledItems.newFile)
        XCTAssertTrue(config.enabledItems.openWith)
        XCTAssertTrue(config.enabledItems.favorites)
        XCTAssertEqual(config.newFileTemplates.map(\.fileExtension), ["md", "txt", "swift"])
        XCTAssertEqual(config.openWithApps.map(\.name), ["TextEdit", "Terminal"])
        XCTAssertEqual(config.favorites.map(\.name), ["Projects"])
    }
}
